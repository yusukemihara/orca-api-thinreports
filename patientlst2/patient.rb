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
  :path => "/api01rv2/patientgetv2?id=00001",
  :ssl  => true,
  :user => "api_mihara3",
  :pass => "5e403a3bbd63e0f98d53befadabaeee76c8ecf3fcd701a80cb0ac9959f9b142b"
}

#opt = {
#  :host => "localhost",
#  :port => 8000,
#  :path => "/api01rv2/patientlst2v2?class=01",
#  :ssl  => false,
#  :user => "ormaster",
#  :pass => "ormaster"
#}

data = <<EOF
<data>
  <patientlst2req type="record">
    <Patient_ID_Information type="array">
      <Patient_ID_Information_child type="record">
        <Patient_ID type="string">1</Patient_ID>
      </Patient_ID_Information_child>
    </Patient_ID_Information>
  </patientlst2req>
</data>
EOF

xml = api_post(opt,data)
unless xml
  puts 'cant get xml'
  exit
end

# 受け取ったXMLのパース
root = Crack::XML.parse(xml)
patient_info = root['xmlio2']['patientinfores']['Patient_Information']
pp patient_info

# Thinreportで帳票作成

report = ThinReports::Report.new :layout => 'patient'
report.start_new_page

ids = %w|Patient_ID WholeName WholeName_inKana BirthDate Sex|
ids.each do |id|
  report.page.item(id.to_sym).value(patient_info[id])
end

#report.page.item(:Patient_ID).value(patient_info['Patient_ID'])
#report.page.item(:WholeName).value(patient_info['WholeName'])
report.page.item(:image).src('orca.jpg')
report.generate :filename => 'patient.pdf'
