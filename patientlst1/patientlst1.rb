# coding:utf-8

require 'pp'
require 'uri'
require 'net/https'
require 'crack'
require 'crack/xml'
require 'thinreports'

Net::HTTP.version_1_2

def api_post(opt,data)
  resbody = nil
  https = Net::HTTP.new(opt[:host],opt[:port])
  https.use_ssl = opt[:ssl]
  https.verify_mode = OpenSSL::SSL::VERIFY_PEER
  https.start do
    req = Net::HTTP::Post.new(opt[:path])
    req.content_length = data.size
    req.body = data
    req.content_type = "application/xml"
    req.basic_auth(opt[:user],opt[:pass])
    res = https.request(req)
    resbody = res.body if res.code == '200'
  end
  resbody
end

# APIで患者情報取得

opt = {
  :host => "sms.orca-ng.org",
  :port => 9201,
  :path => "/api01rv2/patientlst1v2?class=01",
  :ssl  => true,
  :user => "api_mihara3",
  :pass => "5e403a3bbd63e0f98d53befadabaeee76c8ecf3fcd701a80cb0ac9959f9b142b"
}

#opt = {
#  :host => "localhost",
#  :port => 8000,
#  :path => "/api01rv2/patientlst1v2?class=01",
#  :ssl  => false,
#  :user => "ormaster",
#  :pass => "ormaster"
#}

data = <<EOF
<data>
  <patientlst1req type="record">
    <Base_StartDate type="string">2015-04-01</Base_StartDate>
    <Base_EndDate type="string">2015-04-30</Base_EndDate>
    <Contain_TestPatient_Flag type="string">1</Contain_TestPatient_Flag>
  </patientlst1req>
</data>
EOF

xml = api_post(opt,data)
unless xml
  puts 'cant get xml'
  exit
end

# 受け取ったXMLのパース
root = Crack::XML.parse(xml)
patient_info = root['xmlio2']['patientlst1res']['Patient_Information']
pp patient_info

# Thinreportで帳票作成

report = ThinReports::Report.create do
  use_layout 'main', default: true
  use_layout 'cover', id: :cover

  start_new_page layout: :cover

  attrs = %w|Patient_ID WholeName WholeName_inKana BirthDate Sex CreateDate UpdateDate TestPatient_Flag|
  patient_info.each do |p|
    start_new_page do |page|
      attrs.each do |a|
        page.item(a.intern).value(p[a])
      end
    end
  end

  start_new_page layout: 'endcover.tlf'
end
report.generate :filename => 'patientlst1.pdf'
