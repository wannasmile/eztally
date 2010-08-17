#!/usr/bin/env python

import hashlib, datetime
from google.appengine.ext import db
from SimpleXMLRPCServer import CGIXMLRPCRequestHandler

#-------------------------------------------------
class User(db.Model):
  user_id = db.IntegerProperty()
  gmail = db.StringProperty()
  password = db.StringProperty()
  session_key = db.StringProperty()
  last_login = db.DateTimeProperty(auto_now=True)
  
class Tally(db.Model):
  type_id = db.IntegerProperty()
  sub_type_id = db.IntegerProperty()
  count = db.IntegerProperty()
  user_id = db.IntegerProperty()
  date_str = db.StringProperty()
  memo = db.StringProperty(multiline=True)
  time_tag = db.DateTimeProperty(auto_now_add=True)

class MonthTally(db.Model):
  month_str = db.StringProperty()
  type_id = db.IntegerProperty()
  sub_type_id = db.IntegerProperty()
  user_id = db.IntegerProperty()
  count = db.IntegerProperty(default=0)
  
#-------------------------------------------------
def is_user_auth(session_key):
  query = db.Query(User)
  user = query.filter('session_key =', session_key).get()
  return(user <> None)

def get_month_tally(month_str, type_id, sub_type_id, user_id):
  query = db.Query(MonthTally)
  query.filter('month_str =',month_str)
  query.filter('type_id =', type_id)
  query.filter('sub_type_id =', sub_type_id)
  query.filter('user_id =', user_id)
  result = query.get()
  if result is None:
    result = MonthTally(key_name='%s:%d:%02d:%d' %(month_str, type_id, sub_type_id, user_id))
  result.month_str = month_str
  result.type_id = type_id
  result.sub_type_id = sub_type_id
  result.user_id = user_id
  return result
  
#-------------------------------------------------
def user_login(user_id, password):
  query = db.Query(User)
  user = query.filter('user_id =', user_id).get()
  if (user is None) and (user_id >= 0) and (user_id <= 9):
    user = User()
    user.user_id = user_id
    user.password = '123'
  if password == user.password:
    user.session_key = hashlib.md5(str(user_id) + user.password
                                   + str(datetime.datetime.today())).hexdigest()
    user.put()
    return user.session_key
  
def get_last_tallies(session_key, count, offset):
  if is_user_auth(session_key):
    query = db.Query(Tally)
    items = query.order('-time_tag').fetch(count, offset)
    results = []
    for item in items:
      results.append((item.key().id(), item.type_id, item.sub_type_id, item.count, item.user_id, item.date_str, item.memo))
    return results
 
def get_tallies(session_key, from_date, to_date, type_id, sub_type_id, user_id):
  if is_user_auth(session_key):
    query = db.Query(Tally)
    query.filter('date_str >=', from_date)
    query.filter('date_str <=', to_date)
    if type_id <> -1:
      query.filter('type_id =', type_id)
    if sub_type_id <> -1:
      query.filter('sub_type_id =', sub_type_id)
    if user_id <> -1:
      query.filter('user_id =', user_id)
    items = query.order('date_str').fetch(1000)
    results = []
    for item in items:
      results.append((item.key().id(), item.type_id, item.sub_type_id, item.count, item.user_id, item.date_str, item.memo))
    return results

def add_tally(session_key, type_id, sub_type_id, count, user_id, date_str, memo):
  if is_user_auth(session_key):
    item = Tally()
    item.type_id = type_id
    item.sub_type_id = sub_type_id
    item.count = count
    item.user_id = user_id
    item.date_str = date_str
    item.memo = memo
    month_tally = get_month_tally(date_str[:7], type_id, sub_type_id, user_id)
    month_tally.count +=  count
    month_tally.put()
    return item.put().id()

def save_tally(session_key, id, type_id, sub_type_id, count, user_id, date_str, memo):
  if is_user_auth(session_key):
    item = Tally.get_by_id(id)
    old_month_tally = get_month_tally(item.date_str[:7], item.type_id, item.sub_type_id, item.user_id)
    old_month_tally.count -= item.count
    old_month_tally.put()
    if old_month_tally.count <> 0:
      old_month_tally.put()
    else:
      old_month_tally.delete()
    month_tally = get_month_tally(date_str[:7], type_id, sub_type_id, user_id)
    month_tally.count +=  count
    month_tally.put()
    item.type_id = type_id
    item.sub_type_id = sub_type_id
    item.count = count
    item.user_id = user_id
    item.date_str = date_str
    item.memo = memo
    return item.put().id()
    
def del_tally(session_key, id):
  if is_user_auth(session_key):
    item = Tally.get_by_id(id)
    month_tally = get_month_tally(item.date_str[:7], item.type_id, item.sub_type_id, item.user_id)
    month_tally.count -= item.count
    if month_tally.count <> 0:
      month_tally.put()
    else:
      month_tally.delete()
    item.delete()
    return True

def get_stat_report(session_key, start_month, end_month, user_id):
  if is_user_auth(session_key):
    query = db.Query(MonthTally)
    query.filter('month_str >=', start_month).filter('month_str <=', end_month)
    if user_id <> -1:
      query.filter('user_id =', user_id)
    results = query.fetch(1000)

    t0_sub_type_stat = {}
    t1_sub_type_stat = {}
    t0_month_stat = {'9999-12': 0}
    t1_month_stat = {'9999-12': 0}
    for item in results:
      sub_type_id_str = str(item.sub_type_id)
      if item.type_id == 0:
        t0_month_stat['9999-12'] += item.count
        if t0_sub_type_stat.get(sub_type_id_str) is None:
          t0_sub_type_stat[sub_type_id_str] = item.count
        else:
          t0_sub_type_stat[sub_type_id_str] += item.count
        if t0_month_stat.get(item.month_str) is None:
          t0_month_stat[item.month_str] = item.count
        else:
          t0_month_stat[item.month_str] += item.count
      if item.type_id == 1:
        t1_month_stat['9999-12'] += item.count
        if t1_sub_type_stat.get(sub_type_id_str) is None:
          t1_sub_type_stat[sub_type_id_str] = item.count
        else:
          t1_sub_type_stat[sub_type_id_str] += item.count
        if t1_month_stat.get(item.month_str) is None:
          t1_month_stat[item.month_str] = item.count
        else:
          t1_month_stat[item.month_str] += item.count

    stat_report = []
    keys = t0_sub_type_stat.keys()
    keys.sort()
    stat_items = []
    for key in keys:
      stat_items.append((key, t0_sub_type_stat[key]))
    stat_report.append((stat_items))

    keys = t1_sub_type_stat.keys()
    keys.sort()
    stat_items = []
    for key in keys:
      stat_items.append((key, t1_sub_type_stat[key]))
    stat_report.append((stat_items))

    keys = t0_month_stat.keys()
    keys.sort()
    stat_items = []
    for key in keys:
      stat_items.append((key, t0_month_stat[key]))
    stat_report.append((stat_items))

    keys = t1_month_stat.keys()
    keys.sort()
    stat_items = []
    for key in keys:
      stat_items.append((key, t1_month_stat[key]))
    stat_report.append((stat_items))

    return stat_report

def get_month_total(session_key, month):
  if is_user_auth(session_key):
    query = db.Query(MonthTally)
    query.filter('month_str =', month)
    results = query.fetch(1000)

    t0_total = 0
    t1_total = 0
    for item in results:
      if item.type_id == 0:
        t0_total += item.count
      if item.type_id == 1:
        t1_total += item.count

    return [t0_total, t1_total]

#-------------------------------------------------
handler = CGIXMLRPCRequestHandler()
handler.register_introspection_functions()
handler.register_function(user_login)
handler.register_function(get_last_tallies)
handler.register_function(get_tallies)
handler.register_function(add_tally)
handler.register_function(save_tally)
handler.register_function(del_tally)
handler.register_function(get_stat_report)
handler.register_function(get_month_total)
handler.handle_request()

