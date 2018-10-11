require 'spec_helper'

module TestApp
  extend EZApi::Client

  api_url 'www.example.com/api/'
  api_key 'secret_api_key'

  class User < EZApi::ObjectBase
    actions [:show, :save, :create, :delete, :update, :index]
  end

  class CustomPath < EZApi::ObjectBase
    path 'this_custom_path'
  end
end

RSpec.describe EZApi::ObjectBase do
  describe '#api_path' do
    it 'should set the api_path' do
      expect(TestApp::User.api_path).to eq('users')
    end

    it 'should be able to be overwritten' do
      expect(TestApp::CustomPath.api_path).to eq('this_custom_path')
    end
  end

  describe '#client' do
    it 'should be able to call the client' do
      expect(TestApp::User.respond_to?(:client)).to eq true
    end
  end

  describe '#actions' do
    before do
      allow(TestApp::User).to receive(:request).and_return({})
    end

    it 'should set actions' do
      [:show, :create, :delete, :update, :index].each do |action|
        expect(TestApp::User.respond_to?(action)).to eq true
      end

      [:save, :delete].each do |action|
        expect(TestApp::User.new.respond_to?(action)).to eq true
      end
    end
  end

  describe '#assign_attributes' do
    let(:user) { TestApp::User.new }
    let(:params) {{first_name: 'nick', last_name: 'example'}}

    before do
      user.send(:assign_attributes, params)
    end

    context 'basic params' do
      it 'should set attributes on the model' do
        params.each do |key, value|
          expect(user.send(key)).to eq value
        end
      end
    end

    describe 'arrays' do
      context 'arrays of objects' do
        let(:params) {  {items: [{name: 'Item1'}, {name: 'Item2'}]} }

        it 'should create an array of ObjectBase objects' do
          user.items.each do |item|
            expect(item.respond_to?(:name))
          end
        end
      end

      context 'arrays of non objects' do
        let(:item_ids) { ['1', '2'] }
        let(:params) { {item_ids: item_ids} }

        it 'should do nothing special' do
          expect(user.item_ids).to match_array(item_ids)
        end
      end

    end

    context 'nested objects' do
      let(:params) { {address: {street: '123 main st', city: 'San Francisco'}} }

      it 'should create ObjectBase for each object' do
        expect(user.address.street).to eq '123 main st'
        expect(user.address.city).to eq 'San Francisco'
      end
    end
  end
end
