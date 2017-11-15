# !-*- coding:utf-8 -*-
from __future__ import with_statement
import base64, binascii, bz2, cgi, copy, email, gc, gzip, hashlib, inspect, json
import logging, math, md5, os, pickle, random, re, StringIO, sys
import tarfile, threading, time, traceback, unicodedata, urllib
import webapp2, zlib
import lxml.html
from datetime import datetime, timedelta, tzinfo
from lxml.html.diff import htmldiff
from urlparse import urlparse
from uuid import uuid4
from xml.dom import minidom
from xml.etree import ElementTree
from xml.sax import saxutils
from google.appengine.api import app_identity
from google.appengine.api import capabilities
from google.appengine.api import datastore_errors
from google.appengine.api import images
from google.appengine.api import logservice
from google.appengine.api import mail
from google.appengine.api import memcache
from google.appengine.api import modules
from google.appengine.api import runtime
from google.appengine.api import urlfetch
from google.appengine.api import users
from google.appengine.api import taskqueue
from google.appengine.api.taskqueue import TaskAlreadyExistsError
from google.appengine.api.taskqueue import TombstonedTaskError
from google.appengine.api.taskqueue import TransientError
from google.appengine.ext import blobstore
from google.appengine.ext import db
from google.appengine.ext.db import stats
from google.appengine.ext.db import BadRequestError
from google.appengine.ext.webapp import blobstore_handlers
from google.appengine.ext.webapp.mail_handlers import InboundMailHandler
from google.appengine.runtime import apiproxy_errors
from google.appengine.runtime import DeadlineExceededError

#----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----
# Utility
#----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----

class MyUtils3:
	"""
	MyUtils3
	"""

	@staticmethod
	def get_invoke_class_name():
		"""
		呼び出し元クラス名取得
		"""
		class_name = '...'
		# 最大10階層まで遡る
		for i in xrange(1, 10):
			try:
				class_name = inspect.getargvalues(inspect.stack()[i][0]).locals['self'].__class__.__name__
				break
			except KeyError:
				pass
			except:
				class_name = '...'
				break
		return class_name

	@staticmethod
	def urlfetch_post(url_, post_data_, deadline_=60, log_prefix_='', error_logging_=True, retry_count_=0, headers_=None, follow_redirects_=True):
		"""
		POST
		"""
		log_prefix = log_prefix_
		if log_prefix == '':
			log_prefix = '[{0}]'.format(MyUtils3.get_invoke_class_name())
		logging.info('{0}[POST]{1}'.format(log_prefix, url_))
		result = None
		try:
			if headers_ is None:
				headers = {
						'Cache-Control' : 'no-cache,max-age=0',
						'Pragma' : 'no-cache',
						}
			else:
				headers = headers_

			for i in xrange(-1, retry_count_):
				try:
					result = urlfetch.fetch(
										url=url_,
										payload=urllib.urlencode(post_data_),
										method=urlfetch.POST,
										headers=headers,
										deadline=deadline_,
										follow_redirects=follow_redirects_
										)
					break
				except:
					if i == (retry_count_ - 1):
						raise
					else:
						MyUtils3.logging_info('RETRY : {0} URL : {1}'.format(str(i + 2), url_))
		except:
			if error_logging_:
				logging.warning('{0}[POST]{1}'.format(log_prefix, url_))
			headers = None
			del headers
			raise

		headers = None
		del headers, log_prefix
		return result

	@staticmethod
	def urlfetch_get(url_, deadline_=60, log_prefix_='', error_logging_=True, retry_count_=0, headers_=None, follow_redirects_=True):
		"""
		GET
		"""
		log_prefix = log_prefix_
		invoke_class_name = MyUtils3.get_invoke_class_name()
		if log_prefix == '':
			log_prefix = '[{0}]'.format(invoke_class_name)
		logging.info('{0}[GET]{1}'.format(log_prefix, url_))
		result = None
		headers = None
		try:
			if headers_ is None:
				headers = {
						'Cache-Control' : 'no-cache,max-age=0',
						'Pragma' : 'no-cache',
						}
			else:
				headers = headers_

			for i in xrange(-1, retry_count_):
				try:
					result = urlfetch.fetch(
										url=url_,
										method=urlfetch.GET,
										headers=headers,
										deadline=deadline_,
										follow_redirects=follow_redirects_
										)
					break
				except:
					if i == (retry_count_ - 1):
						raise
					else:
						MyUtils3.logging_info('RETRY : {0} URL : {1}'.format(str(i + 2), url_))
		except:
			if error_logging_:
				logging.warning('{0}[GET]{1}'.format(log_prefix, url_))
			headers = None
			del headers
			raise
		headers = None
		del headers, log_prefix
		return result

	@staticmethod
	def logging_info(message_):
		"""
		logging.info 呼出元インスタンスのクラス名を自動付与
		"""
		log_prefix = '[{0}]'.format(MyUtils3.get_invoke_class_name())
		logging.info(log_prefix + str(message_))
		del log_prefix
		return

	@staticmethod
	def logging_warning(message_):
		"""
		logging.warning 呼出元インスタンスのクラス名を自動付与
		"""
		log_prefix = '[{0}]'.format(MyUtils3.get_invoke_class_name())
		logging.warning(log_prefix + str(message_))
		del log_prefix
		return

#----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----
# Data Entity
#----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----

class ServerData(db.Model):
	"""
	振分対象サーバ
	"""
	fqdn = db.StringProperty(required = True, default='*')
	start_hour = db.IntegerProperty(required = True, default = -1, indexed = True)
	end_hour = db.IntegerProperty(required = True, default = -1, indexed = True)

#----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----
# Main
#----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----

class Rss010(webapp2.RequestHandler):
	"""
	LB
	"""
	def get(self, path_):
		"""
		get
		"""

		try:
			hour = datetime.utcnow().hour

			sd = db.GqlQuery('SELECT fqdn FROM ServerData WHERE start_hour >= :hour AND end_hour <= :hour', hour=hour).get()
			MyUtils3.logging_info(sd.fqdn)

			url = 'https://' + sd.fqdn + '/' + path_

			result = MyUtils3.urlfetch_get(url, 35)

			self.response.headers['Content-Type'] = 'application/xml; charset=UTF-8'
			self.response.out.write(result.content)
		except:
			MyUtils3.logging_warning(traceback.format_exc())

		return

class MainPage(webapp2.RequestHandler):
	"""
	Hello World
	"""
	def get(self):
		"""
		get
		"""

		MyUtils3.logging_info(modules.get_current_module_name())

		MyUtils3.logging_info(self.request.uri)
		MyUtils3.logging_info(str(self.request))
		for name in os.environ.keys():
			MyUtils3.logging_info('{0} : {1}'.format(name, os.environ[name]))

		self.response.headers['Content-Type'] = 'text/plain'
		self.response.out.write('Hello World')

		return

app = webapp2.WSGIApplication([
							('/rss010/(.+)', Rss010),
							('/', MainPage),
							],
							debug=True)
