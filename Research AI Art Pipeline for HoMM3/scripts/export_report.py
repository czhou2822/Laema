from pathlib import Path
from playwright.sync_api import sync_playwright
import json
from http.server import BaseHTTPRequestHandler, HTTPServer
from threading import Thread

r=Path(__file__).resolve().parents[1];errors=[]
class ReportHandler(BaseHTTPRequestHandler):
 def do_GET(self):
  if self.path!='/report.html':self.send_error(404);return
  content=(r/'report.html').read_bytes();self.send_response(200);self.send_header('Content-Type','text/html; charset=utf-8');self.send_header('Content-Length',str(len(content)));self.end_headers();self.wfile.write(content)
 def log_message(self,*args):pass
server=HTTPServer(('127.0.0.1',0),ReportHandler)
Thread(target=server.serve_forever,daemon=True).start()
with sync_playwright() as p:
 browser=p.chromium.launch(executable_path='/usr/bin/chromium',headless=True,args=['--no-sandbox','--disable-dev-shm-usage'])
 page=browser.new_page(viewport={'width':1440,'height':1000},device_scale_factor=1)
 page.on('pageerror',lambda e: errors.append(str(e)))
 page.goto(f'http://127.0.0.1:{server.server_port}/report.html',wait_until='load')
 page.wait_for_function('window.REVIEW_READY === true')
 page.locator('#animation-canvas').scroll_into_view_if_needed()
 page.screenshot(path=str(r/'report_interactive_preview.png'))
 page.locator('#frame').fill('3');page.locator('#frame').dispatch_event('input')
 assert '03' in page.locator('#framevalue').inner_text()
 page.locator('#overlay').check();page.locator('#bg').select_option('#ffffff')
 page.locator('#zoom').select_option('2')
 assert page.locator('#animation-canvas').get_attribute('width')=='2336'
 page.locator('#play').click();page.wait_for_timeout(250);page.locator('#play').click()
 page.locator('#zoom').select_option('1');page.locator('#overlay').uncheck()
 page.emulate_media(media='print')
 page.pdf(path=str(r/'report.pdf'),format='A4',print_background=True,display_header_footer=True,header_template='<span></span>',footer_template='<div style="font-size:8px; width:100%; text-align:center; color:#64748b">HoMM3 pipeline research · 23 October 2026 · <span class="pageNumber"></span> / <span class="totalPages"></span></div>',prefer_css_page_size=True)
 result={'javascript_errors':errors,'images':page.locator('figure img').count(),'broken_images':page.evaluate('Array.from(document.images).filter(i=>!i.complete||i.naturalWidth===0).length'),'scrub_overlay_background_zoom_play_controls':'passed','pdf_bytes':(r/'report.pdf').stat().st_size}
 browser.close()
server.shutdown();server.server_close()
(r/'report_checks.json').write_text(json.dumps(result,indent=2));print(json.dumps(result))
