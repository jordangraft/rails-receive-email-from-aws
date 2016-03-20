class Email < ActiveRecord::Base

	def self.process_incoming_email(message_id)
		obj = AWS::S3.new.buckets['my-email-bucket'].objects[message_id]
		contents = obj.read
		from = contents.match(/(?<=From: )(.*?)(?=\n)/).try(:to_s)
		to = contents.match(/(?<=To: )(.*?)(?=\n)/).try(:to_s)
		subject = contents.match(/(?<=Subject: )(.*?)(?=\n)/).try(:to_s)
		body = contents.match(/(?<=Content-Type: text\/html; charset\=UTF-8)(.*?)(?=--)/m).try(:to_s)
		self.create(
			from: from,
			to: to,
			subject: subject,
			body: body
		)
	end	

end
