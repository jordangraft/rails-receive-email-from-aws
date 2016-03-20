require 'rails_helper'


RSpec.describe EmailsController, type: :controller do

  context 'receive a post from Lambda' do

    it 'should be receive a message from email via Lambda' do
      expect { post(:incoming, token: 'test_token', message_id: 'test') }.to change { Email.count }.by(1)
    end
    
    it 'should be be unauthorized without the lamda token' do
      response = post :incoming, message_id: 'test'
      expect(response.status).to eq(401)
    end
  end

end
