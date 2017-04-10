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
    is_expected.to route_command('add foo to bar').to(:add_group_member)
    is_expected.to route_command('remove foo from bar').to(:remove_group_member)
  end

  let(:locked_user) do
    testuser = instance_double(
      'Cratus::User',
      dn: 'cn=jdoe,dc=example,dc=com',
      lockouttime: '124',
      locked?: true,
      unlock: true
    )
    testuser
  end

  let(:unlocked_user) do
    testuser = instance_double(
      'Cratus::User',
      dn: 'cn=jdoe,dc=example,dc=com',
      lockouttime: '0',
      locked?: false
    )
    testuser
  end

  let(:simple_group) do
    instance_double(
      'Cratus::Group',
      dn: 'cn=testgroup,dc=example,dc=com',
      add_user: true,
      remove_user: true
    )
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
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::LDAP).to receive(:connection).and_return(true)
      allow(Cratus::User).to receive(:new).and_return(locked_user)
      send_command('unlock jdoe')
      expect(replies.first).to eq('lets see what we can do')
      expect(replies.last).to eq("'jdoe' has been unlocked")
    end
    it 'lets you know if the user is not locked' do
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::LDAP).to receive(:connection).and_return(true)
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      allow(Cratus::LDAP.connection).to receive(:replace_attribute).and_return(true)
      send_command('unlock jdoe')
      expect(replies.first).to eq('lets see what we can do')
      expect(replies.last).to eq("'jdoe' is not locked")
    end
  end

  describe '#add_group_member' do
    it 'adds a user to a group' do
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::LDAP).to receive(:connection).and_return(true)
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      allow(Cratus::Group).to receive(:new).and_return(simple_group)
      send_command('add jdoe to testgroup')
      expect(replies.first).to eq("I'll get that user added")
      expect(replies.last).to eq("'jdoe' is now a member of 'testgroup'")
    end
  end

  describe '#remove_group_member' do
    it 'removes a user from a group' do
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::LDAP).to receive(:connection).and_return(true)
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      allow(Cratus::Group).to receive(:new).and_return(simple_group)
      send_command('remove jdoe from testgroup')
      expect(replies.first).to eq('Give me just a second to remove that user from the group')
      expect(replies.last).to eq("'jdoe' is no longer a member of 'testgroup'")
    end
  end
end
