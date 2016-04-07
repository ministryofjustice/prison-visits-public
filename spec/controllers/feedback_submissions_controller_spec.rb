require 'rails_helper'

RSpec.describe FeedbackSubmissionsController, type: :controller do
  context 'new' do
    let(:params) { { locale: 'en' } }
    it 'responds with success' do
      get :new, params
      expect(response).to be_success
    end

    it 'renders the new template' do
      get :new, params
      expect(response).to render_template('new')
    end
  end

  context 'create' do
    context 'with a successful feedback submission' do
      before do
        allow_any_instance_of(PrisonVisits::Api).to receive(:create_feedback)
      end
      let(:params) {
        {
          feedback_submission: {
            email_address: 'test@example.com ', body: 'feedback', referrer: 'ref'
          },
          locale: 'en'
        }
      }

      it 'renders the create template' do
        post :create, params
        expect(response).to render_template('create')
      end

      it 'sends to the API' do
        expect_any_instance_of(PrisonVisits::Api).
          to receive(:create_feedback).with(instance_of(FeedbackSubmission))
        post :create, params
      end
    end

    context 'with no body entered' do
      let(:params) {
        {
          feedback_submission: {
            email_address: 'test@maildrop.dsd.io', body: '', referrer: 'ref'
          },
          locale: 'en'
        }
      }

      it 'responds with success' do
        post :create, params
        expect(response).to be_success
      end

      it 'does not send to the API' do
        expect_any_instance_of(PrisonVisits::Api).
          to_not receive(:create_feedback)
        post :create, params
      end

      it 're-renders the new template' do
        post :create, params
        expect(response).to render_template('new')
      end
    end
  end
end
