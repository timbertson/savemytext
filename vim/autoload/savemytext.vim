python << PY
import sys, os, re
import commands
try:
	import savemytext
except ImportError:
	# if you don't put it in your PYTHONPATH, you should use zeroinstall :)
	smtpath = commands.getoutput("0launch -c 'http://gfxmonk.net/dist/0install/0find.xml' 'http://gfxmonk.net/dist/0install/savemytext.xml'")
	print smtpath
	if not smtpath in sys.path:
		sys.path.insert(0, smtpath)
	# how about now?
	import savemytext
import savemytext.api
import vim

class SaveMyText(object):
	def __init__(self, user=None):
		if user is None:
			user, _ = self.parse()
		self.user = user
		print "loading..."
		self.smt = savemytext.api.Texts(savemytext.api.init_api(user))
	
	def parse(self):
		url = vim.eval('file')
		protocol, path = url.split(":", 1)
		user, text = path.split("/", 1)
		return (user, text)

	def get_doc(self, text):
		try:
			doc = self.smt.find(text)
		except StandardError, e:
			doc = self.smt.new(title=text)
		return doc

	def onload(self):
		_, text = self.parse()
		doc = self.get_doc(text)
		vim.current.buffer[:] = map(str, doc['content'].splitlines())
		vim.command("set buftype=acwrite")
		vim.command(":filetype detect")
	
	def onsave(self):
		_, text = self.parse()
		doc = self.get_doc(text)
		doc['content'] = "\n".join(vim.current.buffer)
		self.smt.save(doc)
	
	def list(self):
		filename = vim.eval("tempname()")
		with open(filename, 'w') as f:
			print >> f, "\n".join(["smt:%s/%s" % (self.user, re.escape(doc['title']),) for doc in self.smt.contents])
		old_format = vim.eval('&efm')
		vim.command('cgetfile %s' % (filename,))
		vim.command('copen')
	
	def remove(self, text):
		doc = self.get_doc(text)
		title = doc['title'].replace("\"","")
		if vim.eval('confirm("really remove %s?", "yes\nno")' % (title,)) == 1:
			#self.smt.remove(doc)
			print "REMOVED: %s" % (doc['title'],)
PY

" -----------------------------

function! savemytext#SmtEdit(url) abort
	if a:url=="<afile>"
		let file=expand(a:url)
	else
		let file=a:url
	endif
	py SaveMyText().onload()
endfunction

function! savemytext#SmtWrite (url) abort
	if a:url=="<afile>"
		let file=expand(a:url)
	else
		let file=a:url
	endif
	py SaveMyText().onsave()
	set nomodified
endf

function! savemytext#SmtList (user) abort
	let g:smtformat="%f"
	let efm_bak=&efm
	try
		let &efm=g:smtformat
		py SaveMyText(vim.eval("a:user")).list()
	finally
		let &efm=efm_bak
	endtry
endf

function! savemytext#SmtDelete (user, text) abort
	py SaveMyText(vim.eval("a:user")).remove(vim.eval("a:text"))
endf

