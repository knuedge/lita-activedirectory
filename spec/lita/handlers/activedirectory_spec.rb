require 'spec_helper'

describe Lita::Handlers::Activedirectory, lita_handler: true do
  before do
    registry.config.handlers.activedirectory.host = 'ldap.example.com'
    registry.config.handlers.activedirectory.basedn = 'dc=example,dc=com'
    registry.config.handlers.activedirectory.user_basedn = 'ou=users,dc=example,dc=com'
    registry.config.handlers.activedirectory.group_basedn = 'ou=groups,dc=example,dc=com'
    registry.config.handlers.activedirectory.username = 'user'
    registry.config.handlers.activedirectory.password = 'pass'
  end

  it 'should have the necessary routes' do
    is_expected.to route_command('is jdoe locked').to(:user_locked?)
    is_expected.to route_command('is jdoe locked?').to(:user_locked?)
    is_expected.to route_command('unlock jdoe').to(:unlock)
    is_expected.to route_command('jdoe groups').to(:user_groups)
  end

  let(:locked_user) do
    testuser = instance_double(
      'Cratus::User',
      lockouttime: '124',
      locked?: true
    )
    testuser
  end

  let(:unlocked_user) do
    testuser = instance_double(
      'Cratus::User',
      lockouttime: '0',
      locked?: false
    )
    testuser
  end

  describe '#user_locked?' do
    it 'lets you know if the user is locked' do
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::User).to receive(:new).and_return(locked_user)
      send_command('is jdoe locked?')
      expect(replies.first).to eq('let me check on that')
      expect(replies.last).to eq("looks like 'jdoe' is locked")
    end
    it 'lets you know if a user is not locked' do
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      send_command('is jdoe locked?')
      expect(replies.first).to eq('let me check on that')
      expect(replies.last).to eq("'jdoe' is not locked")
    end
  end
end
