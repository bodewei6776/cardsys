# To change this template, choose Tools | Templates
# and open the template in the editor.
require File.dirname(__FILE__)+  '/pinyin'
pinyin = PinYin.instance 
puts pinyin.to_pinyin("wangdan")
