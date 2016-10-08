import os
import sys

from jinja2 import Template
from pprint import pformat
import yaml

APP_DIR = os.path.dirname(__file__)
HOST_VARS = os.path.join(APP_DIR, 'host_vars.yml')
TEMPLATE_ROOT = os.path.join(APP_DIR, 'templates')

class TemplateNotFound(Exception):
    pass

class HostVarsNotFound(Exception):
    pass

def get_requestor_vars(requestor_ip):
    try:
        host_vars = yaml.load(open(HOST_VARS)).get(requestor_ip)
    except:
        raise HostVarsNotFound(requestor_ip)
    return host_vars

def get_named_template(name):
    template_path = TEMPLATE_ROOT + name
    try:
        template = open(template_path).read()
    except IOError as e:
        raise TemplateNotFound(template_path)
    return template

def kickstart_template(template_name=None, requestor_ip=None):
    variables = get_requestor_vars(requestor_ip)
    template = get_named_template(template_name)
    return Template(template).render(**variables)

def application(env, start_response):
    try:
        response = '# Generated kickstart file for {} from {}\n\n{}\n'.format(
            env['REMOTE_ADDR'],
            env['REQUEST_URI'],
            kickstart_template(template_name=env['REQUEST_URI'], requestor_ip=env['REMOTE_ADDR'])
        )
        
        start_response('200 OK', [('Content-Type','text/html')])
    except Exception as e:
        start_response('404 ', [('Content-Type','text/html')])
        response = '{}\n'.format(pformat(e))

    return [response]

if __name__ == '__main__':
    def start_response(text, headers): 
        print text
        print headers
    print  '\n{}'.format(application(yaml.load(sys.argv[1]), start_response))
