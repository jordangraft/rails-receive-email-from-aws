require 'rails_helper'

RSpec.describe Email, type: :model do

	let(:message_id)	{ 'test' }

	it 'should be able to read an email from S3 and create an email' do
		email = Email.process_incoming_email(message_id)
		expect(email.valid?).to eq(true)
		expect(email.from).to eq("Sender CrateBind <sender@cratebind.com>")
		expect(email.to).to eq("recipient@emails.cratebind.com")
		expect(email.subject).to eq('test email')
		expect(email.body).to_not eq('<div dir="ltr">some body</div>')
	end

end
