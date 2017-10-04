import os
import string
import cherrypy
from jinja2 import Environment, FileSystemLoader

updateControlFileName = "/home/acn-iot/updates_are_enabled"

class DeviceSettings(object):
    @cherrypy.expose
    def index(self):
        return """<html>
           <head></head>
           <body>
              <h2>Device management</h2>
              <p><a href=wifi_configuration>Configure wifi</a></p>
              <p><a href=manage_updates>Manage updates</a></p>
              <p></p>
              <p>Version: %s</p>
           </body>
           </html>
           """ % os.environ.get('RPP_BASE_SCRIPT_VERSION')

    @cherrypy.expose
    def wifi_configuration(self):
        return """<html>
          <head></head>
          <body>
            <h2>Wifi settings:</h2>
            <form method="get" action="savewifi">
              <table>
                 <tr><td>SSID:</td><td><input type="text" name="SSID" /></td><td></td></tr>
                 <tr><td>Key:</td><td><input type="text" name="Key" /></td><td></td></tr>
                 <tr><td></td><td></td><td><button type="submit">Save</button></td></tr>
              </table>
            </form>
          <p><a href=index>Return to main page</a></p>
          </body>
        </html>"""

    @cherrypy.expose
    def savewifi(self, SSID, Key):
        fname = "/etc/wpa_supplicant/wpa_supplicant.conf"
        template_name = "wpa_supplicant.template"
        context = {
           'wlanSSID': SSID,
           'wlanKey': Key
        }
        with open(fname, 'w') as f:
           config = render_template(template_name, context)
           f.write(config)
        msg = 'Wifi configured with SSID: ' + SSID + ', Key: ' + Key + '.</br>'
        msg = msg + 'Please reboot.'
        return msg

    @cherrypy.expose
    def manage_updates(self):
      if os.path.exists(updateControlFileName):
        msg = """<html>
        <head></head>
        <body>
          <h2>Update management</h2>
          <p>Updates are currently enabled</p>
          <form method="get" action="disable_updates">
            <button type="submit">Disable updates</button>
          </form>
        <p><a href=index>Return to main page</a></p>
        </body>
        <html>"""
      else:
        msg = """<html>
        <head></head>
        <body>
          <h2>Update management</h2>
          <p>Updates are currently disabled</p>
          <form method="get" action="enable_updates">
            <button type="submit">Enable updates</button>
          </form>
          <p><a href=index>Return to main page</a></p>
       </body>
        <html>"""
      return msg

    @cherrypy.expose
    def disable_updates(self):
      if os.path.exists(updateControlFileName):
        os.remove(updateControlFileName)
      msg = """<html><head></head><body>
         <p>Updates are now disabled until you enable them again.</p>
         <p><a href=index>Return to main page</a></p>
         </body></html>"""
      return msg

    @cherrypy.expose
    def enable_updates(self):
      with open(updateControlFileName, 'a'):
        os.utime(updateControlFileName, None)
      msg = """<html><head></head><body>
         <p>The next update is enabled. Please let the device on for the next hour</p>
         <p><a href=index>Return to main page</a></p>
         </body></html>"""
      return msg

def render_template(template_filename, context):
    return TEMPLATE_ENVIRONMENT.get_template(template_filename).render(context)

if __name__ == '__main__':
    PATH = os.path.dirname(os.path.abspath(__file__))
    TEMPLATE_ENVIRONMENT = Environment(
       autoescape=False,
       loader=FileSystemLoader(PATH),
       trim_blocks=False)

    cherrypy.config.update({'server.socket_host': '0.0.0.0' })
    cherrypy.quickstart(DeviceSettings())

