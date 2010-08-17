#!/usr/bin/env python
#coding=gbk

import xmlrpclib, base64, sys

proxy = xmlrpclib.ServerProxy('http://eztally.appspot.com')
#proxy = xmlrpclib.ServerProxy('http://localhost:8080')
#sk = proxy.user_login(0, '123')
print sk
#print proxy.get_stat_report(sk, '2010-02', '2010-05', -1)
#print proxy.get_last_tallies(sk, 1, 1) 
#id = proxy.add_tally(sk, 1, 1, 100, 0, '2010-06-19', 'memo')
#print proxy.save_tally(sk, id, 1, 1, 100, 0, '2010-6-20', 'new memo') 
#print proxy.get_last_tallies(sk, -1) 
#print proxy.del_tally(sk, id) 
#print base64.encodestring('备注')
#print base64.decodestring('sbjXog==')
#print proxy.get_month_total(sk, '2010-06')