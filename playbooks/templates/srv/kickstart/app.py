# pylint: disable=broad-except
import os
import sys
from pprint import pformat

import yaml
from jinja2 import Template


APP_DIR = os.path.dirname(__file__)
HOST_VARS = os.path.join(APP_DIR, 'host_vars.yml')
TEMPLATE_ROOT = os.path.join(APP_DIR, 'templates')

class TemplateNotFound(Exception):
    pass

class HostVarsNotFound(Exception):
    pass

def get_system_vars(requestor_ip='default'):
    default_host_vars = yaml.load(open(HOST_VARS)).get('default', {})
    try:
        host_vars = yaml.load(open(HOST_VARS)).get(requestor_ip)
    except Exception:
        host_vars = {}
    return host_vars or default_host_vars

def find_template_file(path, name):
    try:
        return os.path.join(path, [f for f in os.listdir(path) if f.startswith(name)][0])
    except:
        raise TemplateNotFound("find_template_file({}, {})".format(path, name))

def get_named_template(name):
    template_path = os.path.join(TEMPLATE_ROOT, os.path.dirname(name))
    template_name = os.path.basename(name)
    template_file = find_template_file(template_path, template_name)
    try:
        template = open(template_file).read()
    except:
        raise TemplateNotFound(template_file)
    return template

def kickstart_template(template_name=None, requestor_ip=None):
    requestor_variables = get_system_vars(requestor_ip)
    server_variables = get_system_vars('server')
    template = get_named_template(template_name)
    return Template(template).render(server=server_variables, target=requestor_variables)

def application(env, start_response):
    try:
        response = '# Generated kickstart file for {} from {}\n{}\n'.format(
            env['REMOTE_ADDR'],
            env['QUERY_STRING'],
            kickstart_template(template_name=env['QUERY_STRING'], requestor_ip=env['REMOTE_ADDR'])
        )

        start_response('200 OK', [('Content-Type', 'text/html')])
    except Exception as err:
        start_response('404 ', [('Content-Type', 'text/html')])
        response = '{}\n'.format(pformat(err))

    return [response]

if __name__ == '__main__':
    def start_response_mock(text, headers):
        print(text)
        print(headers)
    print('\n{}'.format(application(yaml.load(sys.argv[1]), start_response_mock)[0]))
