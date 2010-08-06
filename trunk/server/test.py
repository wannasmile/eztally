#!/usr/bin/env python
#coding=gbk

import xmlrpclib, base64, sys

proxy = xmlrpclib.ServerProxy('http://localhost')
sk = proxy.user_login(0, '123')
print sk
#print proxy.get_stat_report(sk, '2010-02', '2010-05', -1)
print proxy.get_last_tallies(sk, 1, 1) 
#id = proxy.add_tally(sk, 1, 100, 0, '2010-02-19', 'memo')
#print proxy.save_tally(sk, id, 1, 100, 0, '2010-2-19', 'new memo') 
#print proxy.get_last_tallies('ABC', 1) 
#print proxy.del_tally('ABC', id) 

