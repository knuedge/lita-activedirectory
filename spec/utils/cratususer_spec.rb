require 'spec_helper'

describe Utils::Cratususer do
  let(:fake_group1) do
    instance_double(
      'Cratus::Group',
      name: 'lame_group1',
      members: [fake_user2]
    )
  end
  let(:fake_group2) do
    instance_double(
      'Cratus::Group',
      name: 'lame_group2'
    )
  end
  let(:fake_user) do
    fakeuser = instance_double(
      'Cratus::User',
      dn: 'cn=jdoe,dc=example,dc=com',
      username: 'jdoe',
      fullname: 'John Doe',
      member_of: [fake_group1, fake_group2],
      lockouttime: '0',
      locked?: false
    )
    fakeuser
  end

  let(:fake_user2) do
    fakeuser = instance_double(
      'Cratus::User',
      dn: 'cn=fbar,dc=example,dc=com',
      username: 'fabar',
      fullname: 'Foo Bar',
      member_of: [],
      lockouttime: '0',
      locked?: false
    )
    fakeuser
  end

  subject do
    # shut up rspec
    class Dummy
      include Utils::Cratususer
      def config
        conf = OpenStruct.new
        conf.host = 'localhost'
        conf
      end
    end
    allow(Cratus::LDAP).to receive(:connect).and_return(true)
    allow(Cratus::LDAP).to receive(:connection).and_return(true)
    Dummy.new
  end

  describe '#user_groups_query' do
    it 'should return the group memberships' do
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::LDAP).to receive(:connection).and_return(true)
      allow(Cratus::User).to receive(:new).and_return(fake_user)
      expect(subject.user_groups_query('jdoe')).to eq("lame_group1\nlame_group2")
    end
  end

  describe '#group_mem_query' do
    it 'should return members of the group' do
      allow(Cratus::LDAP).to receive(:connect).and_return(true)
      allow(Cratus::LDAP).to receive(:connection).and_return(true)
      allow(Cratus::Group).to receive(:new).and_return(fake_group1)
      expect(subject.group_mem_query('foo')).to eq('Foo Bar')
    end
  end
end
