import scrapy
from selenium import webdriver
from scrapy import Selector
import time
from selenium.webdriver.chrome.options import Options
from scrapy.crawler import CrawlerProcess
from webdriver_manager.chrome import ChromeDriverManager
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import math
import random


class segmentSpider(scrapy.Spider):
    segId = '21774536'
    
    name = 'ub'
    allowed_domains = ['www.google.com']
    start_urls = ['https://www.google.com']
    custom_settings = {
        'FEED_FORMAT': 'csv',
        'FEED_URI': F'{segId}.csv',
        'FEED_EXPORT_ENCODING': 'utf-8'
    }

    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.options = Options()
        # self.options.add_argument(r"user-data-dir=C:\Users\macvi\AppData\Local\Google\Chrome\User Data\Profile 1")
        self.options.add_argument("start-maximized")
        self.options.add_experimental_option("excludeSwitches", ["enable-automation"])
        self.options.add_experimental_option('useAutomationExtension', False)
        self.options.add_argument("--disable-blink-features=AutomationControlled")
        self.options.add_argument(r'user-data-dir = /Users/stu/Library/Application Support/Google/Chrome/Default')
        self.options.add_argument(
            f'--user-agent=Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.190 Safari/537.36')
        self.driver = webdriver.Chrome("./chromedriver", chrome_options=self.options)

    def setup(self):
        self.driver.get('https://strava.com/login')
        self.driver.switch_to.window(self.driver.window_handles[0])


    def login(self):
        time.sleep(1)
        self.driver.find_element(By.ID, "email").send_keys('2023ubcogisproject@gmail.com')
        self.driver.find_element(By.ID, "password").send_keys('now2is41')
        time.sleep(1)
        self.driver.find_element(By.ID, "login-button").click()

    def getSegment(self, segmentCode):
        time.sleep(2)
        self.driver.execute_script("window.open('');")
        time.sleep(2)
        self.driver.switch_to.window(self.driver.window_handles[1])
        time.sleep(2)
        self.driver.get('https://strava.com/segments/' + segmentCode)

# everything happens in parse 
    def parse(self, response):
        # segment code should be a list of all the codes

        self.setup()
        self.login()
        self.getSegment(self.segId)
        time.sleep(3)
        resp = Selector(text=self.driver.page_source)
        pages = math.ceil(int(resp.xpath('//*[@id="segment-results"]/div[2]/table/tbody/tr/td[1]/div/text()').get().replace('\n','').split()[2])/25)
        time.sleep(3)
        for i in range(pages):
            dates = []
            speeds = []
            dateScrape = self.driver.find_elements(By.XPATH, '//*[@id="results"]/table/tbody/tr/td[3]/a')
            for date in dateScrape:
                dates.append(date.text)
            speedScrape = self.driver.find_elements(By.XPATH, '//*[@id="results"]/table/tbody/tr/td[4]')
            for speed in speedScrape:
                speeds.append(speed.text)
            for i in range(len(dates)):
                print(dates[i])
                yield {
                    'date': dates[i],
                    'speed': speeds[i],
                }
            if(i < pages - 1):
                self.driver.find_element(By.XPATH, '//*[@id="results"]/nav/ul/li[last()]/a').click()
                time.sleep(2 + (random.random() * 10))
        time.sleep(1)


process = CrawlerProcess()
process.crawl(segmentSpider)
process.start()