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

  let(:lita_user) { Lita::User.create('User', name: 'A User', mention_name: 'user') }

  it 'should have the necessary routes' do
    is_expected.to route_command('is jdoe locked').to(:user_locked?)
    is_expected.to route_command('is jdoe locked?').to(:user_locked?)
    is_expected.to route_command('unlock jdoe').with_authorization_for(:ad_admins).to(:unlock)
    is_expected.to route_command('jdoe groups').to(:user_groups)
    is_expected.to route_command('group foo members').to(:group_members)
    is_expected.to route_command('add foo to bar')
      .with_authorization_for(:ad_admins).to(:add_group_member)
    is_expected.to route_command('remove foo from bar')
      .with_authorization_for(:ad_admins).to(:remove_group_member)
    is_expected.to route_command('disable user foo')
      .with_authorization_for(:ad_admins).to(:disable_user)
    is_expected.to route_command('enable user foo')
      .with_authorization_for(:ad_admins).to(:enable_user)
  end

  let(:fake_group1) do
    instance_double(
      'Cratus::Group',
      name: 'lame_group1',
      members: [fake_user]
    )
  end

  let(:fake_group2) do
    instance_double(
      'Cratus::Group',
      name: 'lame_group2'
    )
  end

  let(:fake_user) do
    allow(Cratus::LDAP).to receive(:connect).and_return(true)
    allow(Cratus::LDAP).to receive(:connection).and_return(true)
    instance_double(
      'Cratus::User',
      dn: 'cn=fbar,dc=example,dc=com',
      username: 'fabar',
      fullname: 'Foo Bar',
      member_of: [],
      lockouttime: '0',
      locked?: false,
      disable: true,
      enable: true
    )
  end

  let(:locked_user) do
    instance_double(
      'Cratus::User',
      dn: 'cn=jdoe,dc=example,dc=com',
      member_of: [fake_group1, fake_group2],
      lockouttime: '124',
      locked?: true,
      unlock: true
    )
  end

  let(:false_user) do
    allow(Cratus::LDAP).to receive(:connect).and_return(true)
    allow(Cratus::LDAP).to receive(:connection).and_return(true)
    nil
  end

  let(:unlocked_user) do
    instance_double(
      'Cratus::User',
      dn: 'cn=jdoe,dc=example,dc=com',
      username: 'jdoe',
      member_of: [fake_group1, fake_group2],
      lockouttime: '0',
      locked?: false
    )
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
      allow(Cratus::User).to receive(:new).and_return(locked_user)
      send_command('is jdoe locked?')
      expect(replies.first).to eq('let me check on that')
      expect(replies.last).to eq("looks like 'jdoe' is locked")
    end
    it 'lets you know if a user is not locked' do
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      send_command('is jdoe locked?')
      expect(replies.first).to eq('let me check on that')
      expect(replies.last).to eq("'jdoe' is not locked")
    end
  end

  describe '#unlock' do
    before do
      robot.auth.add_user_to_group!(lita_user, :ad_admins)
    end
    it 'unlocks the user when locked' do
      allow(Cratus::User).to receive(:new).and_return(locked_user)
      send_command('unlock jdoe', as: lita_user)
      expect(replies.first).to eq('lets see what we can do')
      expect(replies.last).to eq("'jdoe' has been unlocked")
    end
    it 'lets you know if the user is not locked' do
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      allow(Cratus::LDAP.connection).to receive(:replace_attribute).and_return(true)
      send_command('unlock jdoe', as: lita_user)
      expect(replies.first).to eq('lets see what we can do')
      expect(replies.last).to eq("'jdoe' is not locked")
    end
  end

  describe '#add_group_member' do
    before do
      robot.auth.add_user_to_group!(lita_user, :ad_admins)
    end
    it 'adds a user to a group' do
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::LDAP).to receive(:connection).and_return(true)
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      allow(Cratus::Group).to receive(:new).and_return(simple_group)
      send_command('add jdoe to testgroup', as: lita_user)
      expect(replies.first).to eq("I'll get that user added")
      expect(replies.last).to eq("'jdoe' is now a member of 'testgroup'")
    end
  end

  describe '#remove_group_member' do
    before do
      robot.auth.add_user_to_group!(lita_user, :ad_admins)
    end
    it 'removes a user from a group' do
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::LDAP).to receive(:connection).and_return(true)
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      allow(Cratus::Group).to receive(:new).and_return(simple_group)
      send_command('remove jdoe from testgroup', as: lita_user)
      expect(replies.first).to eq('Give me just a second to remove that user from the group')
      expect(replies.last).to eq("'jdoe' is no longer a member of 'testgroup'")
    end
  end

  describe '#disable_user' do
    before do
      robot.auth.add_user_to_group!(lita_user, :ad_admins)
    end
    it 'disables a user' do
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::LDAP).to receive(:connection).and_return(true)
      allow(Cratus::User).to receive(:new).and_return(fake_user)
      send_command('disable user jdoe', as: lita_user)
      expect(replies.first).to eq("Let's stop that user from logging in then")
      expect(replies.last).to eq("'jdoe' is now disabled")
    end
  end

  describe '#enable_user' do
    before do
      robot.auth.add_user_to_group!(lita_user, :ad_admins)
    end
    it 'enables a user' do
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::LDAP).to receive(:connection).and_return(true)
      allow(Cratus::User).to receive(:new).and_return(fake_user)
      send_command('enable user jdoe', as: lita_user)
      expect(replies.first).to eq("I'll allow this user to login again")
      expect(replies.last).to eq("'jdoe' is now enabled")
    end
  end

  describe '#user_groups' do
    it 'should return proper error mesage' do
      allow(Cratus::User).to receive(:new).and_return(false_user)
      send_command('fbar groups')
      expect(replies.first).to eq('Give me a second to search')
      expect(replies.last)
        .to eq("That did not work, double check that 'fbar' is a valid samAccountName")
    end
    it 'should return group membership' do
      allow(Cratus::User).to receive(:new).and_return(unlocked_user)
      send_command('jdoe groups')
      expect(replies.first).to eq('Give me a second to search')
      expect(replies.last).to eq("lame_group1\nlame_group2")
    end
  end

  describe '#group_members' do
    it 'should return members of the group' do
      allow(Cratus::Group).to receive(:new).and_return(fake_group1)
      send_command('group fake_group1 members')
      expect(replies.first).to eq('Give me a second to search')
      expect(replies.last).to eq('Foo Bar')
    end
  end
end
