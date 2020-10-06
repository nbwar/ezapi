require 'spec_helper'
require 'nokogiri'

module TestApp
  extend EZApi::Client

  api_url 'foo'
  api_key 'bar'

  class User < EZApi::ObjectBase
  end
end

module TestAppWithoutKey
  extend EZApi::Client
  api_url = 'foo'
end

RSpec.describe EZApi::Client do
  describe '#request' do
    context 'success' do
      context "when json response" do
        before do
          response = RestClient::Response.new({success: 'true'}.to_json.to_s)
          allow(response).to receive(:headers).and_return({})
          expect(RestClient::Request).to receive(:execute).and_return(response)
        end

        it 'should parse response' do
          expect(TestApp.request('/url', :post)).to eq({"success"=>"true"})
        end

        context 'custom headers and request arguments' do
          let(:headers) { { content_type: 'text/html' } }
          let(:request_arguments) { { verify_ssl: false } }

          it 'should parse response' do
            expect(TestApp.request('/url', :post, headers, request_arguments )).to eq({"success"=>"true"})
          end
        end
      end

      context "when xml response" do
        before do
          response = RestClient::Response.new("foo")
          allow(response).to receive(:headers).and_return({content_type: "application/xml"})
          expect(RestClient::Request).to receive(:execute).and_return(response)
        end

        it "should call Nokogiri" do
          expect(Nokogiri).to receive(:XML)
          TestApp.request('/url', :post)
        end
      end
    end

    describe 'errors' do
      shared_examples_for 'raises error and sets message' do |error_class|
        it 'should set error message on raised error' do
          begin
            TestApp.request('/url', :post)
          rescue => e
            expect(e.message).to eq(message)
            expect(e.class).to eq(error_class)
          end
        end
      end

      context 'api key not set' do
        it 'should throw AuthenticationError if api_key is not set' do
          expect{TestAppWithoutKey.request('/url', :post)}.to raise_error(EZApi::AuthenticationError)
        end
      end

      describe 'api errors' do
        let(:http_code) { 404 }
        let(:message) { '' }
        let(:http_body) { {'error' => {"message"=>message}}.to_json }

        before do
          allow_any_instance_of(RestClient::ExceptionWithResponse).to receive(:http_code).and_return(http_code)
          allow_any_instance_of(RestClient::ExceptionWithResponse).to receive(:http_body).and_return(http_body)
          expect(RestClient::Request).to receive(:execute).and_raise(RestClient::ExceptionWithResponse)
        end

        context 'Not Found; code 404' do
          let(:http_code) { 404 }
          let(:message) { 'Route does not exits'}
          it_should_behave_like 'raises error and sets message', EZApi::InvalidRequestError
        end

        context 'Bad Request; code 400' do
          let(:http_code) { 400 }
          let(:message) { 'Invalid parameters'}
          it_should_behave_like 'raises error and sets message', EZApi::InvalidRequestError
        end

        context 'Unauthorized; code 401' do
          let(:http_code) { 401 }
          let(:message) { "Unauthorized" }
          it_should_behave_like 'raises error and sets message', EZApi::AuthenticationError
        end
      end

      describe 'RestClient errors' do
        context 'generic restclient error' do
          let(:message) { 'Could not connect to TestApp.'}

          before do
            expect(RestClient::Request).to receive(:execute).and_raise(RestClient::Exception)
          end

          it_should_behave_like 'raises error and sets message', EZApi::ConnectionError
        end

        context 'RestClient::ServerBrokeConnection' do
          let(:message) { 'The connection with TestApp terminated before the request completed.' }
          before do
            expect(RestClient::Request).to receive(:execute).and_raise(RestClient::ServerBrokeConnection)
          end

          it_should_behave_like 'raises error and sets message', EZApi::ConnectionError
        end

        context 'SocketError' do
          let(:message) { 'Could not connect to TestApp.' }
          before do
            expect(RestClient::Request).to receive(:execute).and_raise(SocketError)
          end

          it_should_behave_like 'raises error and sets message', EZApi::ConnectionError
        end

      end
    end
  end

  describe "#raw_request" do
    describe 'errors' do
      shared_examples_for 'raises error and sets message' do |error_class|
        it 'should set error message on raised error' do
          begin
            TestApp.raw_request('/url', :post)
          rescue => e
            expect(e.message).to eq(message)
            expect(e.class).to eq(error_class)
          end
        end
      end

      context 'api key not set' do
        it 'should throw AuthenticationError if api_key is not set' do
          expect{TestAppWithoutKey.raw_request('/url', :post)}.to raise_error(EZApi::AuthenticationError)
        end
      end

      describe 'api errors' do
        let(:http_code) { 404 }
        let(:message) { '' }
        let(:http_body) { {'error' => {"message"=>message}}.to_json }

        before do
          allow_any_instance_of(RestClient::ExceptionWithResponse).to receive(:http_code).and_return(http_code)
          allow_any_instance_of(RestClient::ExceptionWithResponse).to receive(:http_body).and_return(http_body)
          expect(RestClient::Request).to receive(:execute).and_raise(RestClient::ExceptionWithResponse)
        end

        context 'Not Found; code 404' do
          let(:http_code) { 404 }
          let(:message) { 'Route does not exits'}
          it_should_behave_like 'raises error and sets message', EZApi::InvalidRequestError
        end

        context 'Bad Request; code 400' do
          let(:http_code) { 400 }
          let(:message) { 'Invalid parameters'}
          it_should_behave_like 'raises error and sets message', EZApi::InvalidRequestError
        end

        context 'Unauthorized; code 401' do
          let(:http_code) { 401 }
          let(:message) { "Unauthorized" }
          it_should_behave_like 'raises error and sets message', EZApi::AuthenticationError
        end
      end

      describe 'RestClient errors' do
        context 'generic restclient error' do
          let(:message) { 'Could not connect to TestApp.'}

          before do
            expect(RestClient::Request).to receive(:execute).and_raise(RestClient::Exception)
          end

          it_should_behave_like 'raises error and sets message', EZApi::ConnectionError
        end

        context 'RestClient::ServerBrokeConnection' do
          let(:message) { 'The connection with TestApp terminated before the request completed.' }
          before do
            expect(RestClient::Request).to receive(:execute).and_raise(RestClient::ServerBrokeConnection)
          end

          it_should_behave_like 'raises error and sets message', EZApi::ConnectionError
        end

        context 'SocketError' do
          let(:message) { 'Could not connect to TestApp.' }
          before do
            expect(RestClient::Request).to receive(:execute).and_raise(SocketError)
          end

          it_should_behave_like 'raises error and sets message', EZApi::ConnectionError
        end
      end
    end
  end

  describe '#app_name' do
    it 'should be the app name' do
      expect(TestApp.send(:app_name)).to eq('TestApp')
    end
  end

  describe '#full_api_path' do
    let(:base_url) { 'https://instacart.com/api' }
    let(:path) { 'customers' }

    before do
      allow(TestApp).to receive(:base_url).and_return(base_url)
    end

    subject { TestApp::User.client.send(:full_api_path, path) }

    context 'without trailing slash' do
      let(:base_url) { 'https://instacart.com/api' }
      let(:path) { 'customers' }

      it { is_expected.to eq 'https://instacart.com/api/customers' }
    end

    context 'with trailing slash' do
      let(:base_url) { 'https://instacart.com/api/' }
      let(:path) { '/customers/' }

      it { is_expected.to eq 'https://instacart.com/api/customers/' }
    end
  end

end
