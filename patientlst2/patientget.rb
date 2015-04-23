# coding:utf-8

require 'pp'
require 'uri'
require 'net/https'
#require 'crack'
#require 'crack/xml'

Net::HTTP.version_1_2

def api_get(opt)
  https = Net::HTTP.new(opt[:host],opt[:port])
  https.use_ssl = opt[:ssl]
  https.verify_mode = OpenSSL::SSL::VERIFY_PEER
  https.start do
    req = Net::HTTP::Get.new(opt[:path])
    req.basic_auth(opt[:user],opt[:pass])
    res = https.request(req)
    puts res.body
  end
end

opt = {
  :host => "sms.orca-ng.org",
  :port => 9201,
  :path => "/api01rv2/patientgetv2?id=00001",
  :ssl  => true,
  :user => "api_mihara3",
  :pass => "5e403a3bbd63e0f98d53befadabaeee76c8ecf3fcd701a80cb0ac9959f9b142b"
}

#opt = {
#  :host => "localhost",
#  :port => 8000,
#  :path => "/api01rv2/patientgetv2?id=00001",
#  :ssl  => false,
#  :user => "ormaster",
#  :pass => "ormaster"
#}
api_get(opt)
