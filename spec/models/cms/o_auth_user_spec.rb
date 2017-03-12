require 'spec_helper'

describe Cms::OAuthUser do
  context 'when create using omniauth' do
    before do
      @valid_auth = {
        provider: 'facebook',
        uid:      '1234567890',
        info_nickname: 'yamada',
        info_name: '山田 太郎',
        info_image: 'http://example.com/images/yamada.jpg',
        info_url: 'http://example.com/yamada'
      }
    end

    describe 'with valid auth' do
      it 'does not raise error' do
        expect { Cms::OAuthUser.create_or_update_with_omniauth(@valid_auth) }.to_not raise_error
      end
    end

    describe 'with invalid auth' do
      it 'raise error' do
        @valid_auth[:provider] = nil
        expect { Cms::OAuthUser.create_or_update_with_omniauth(@valid_auth) }.to raise_error
      end
    end
  end

  context 'when build' do
    describe 'with valid arguments' do
      it do
        user = FactoryGirl.build(:valid_o_auth_user)
        expect(user).to be_valid
      end
    end

    describe 'without provider' do
      it do
        user = FactoryGirl.build(:valid_o_auth_user, provider: nil)
        expect(user).not_to be_valid
        expect(user.errors[:provider].size).to eq(1)
      end
    end

    describe 'without uid' do
      it do
        user = FactoryGirl.build(:valid_o_auth_user, uid: nil)
        expect(user).not_to be_valid
        expect(user.errors[:uid].size).to eq(1)
      end
    end
  end
end
