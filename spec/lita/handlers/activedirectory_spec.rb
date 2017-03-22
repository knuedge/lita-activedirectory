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
    is_expected.to route_command('group foo members').to(:group_members)
  end

  let(:locked_user) do
    testuser = instance_double(
      'Cratus::User',
      dn: 'cn=jdoe,dc=example,dc=com',
      lockouttime: '124',
      locked?: true
    )
    allow(Cratus::LDAP).to receive(:connect).and_return(true)
    allow(Cratus::LDAP).to receive(:connection).and_return(true)
    testuser
  end

  let(:unlocked_user) do
    testuser = instance_double(
      'Cratus::User',
      dn: 'cn=jdoe,dc=example,dc=com',
      member_of: "['cn=foo,dc=example,dc=com','cn=bar,dc=example,dc=com']",
      lockouttime: '0',
      locked?: false
    )
    allow(Cratus::LDAP).to receive(:connect).and_return(true)
    allow(Cratus::LDAP).to receive(:connection).and_return(true)
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

  describe '#unlock' do
    it 'unlocks the user when locked' do
      allow(Cratus::User).to receive(:new).and_return(locked_user)
      allow(Cratus::LDAP.connection).to receive(:replace_attribute).and_return(true)
      send_command('unlock jdoe')
      expect(replies.first).to eq('lets see what we can do')
      expect(replies.last).to eq("'jdoe' has been unlocked")
    end
    it 'lets you know if the user is not locked' do
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      allow(Cratus::LDAP.connection).to receive(:replace_attribute).and_return(true)
      send_command('unlock jdoe')
      expect(replies.first).to eq('lets see what we can do')
      expect(replies.last).to eq("'jdoe' is not locked")
    end
  end

  describe '#user_groups' do
    it 'should return proper error mesage' do
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      send_command('fbar groups')
      expect(replies.first).to eq('Give me a second to search')
      expect(replies.last)
        .to eq("That did not work, double check that 'fbar' is a valid samAccountName")
    end
    it 'should return group membership' do
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      send_command('fjdoe groups')
      expect(replies.first).to eq('Give me a second to search')
    end
  end
end
