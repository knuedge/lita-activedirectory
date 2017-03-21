module Utils
  # piggy back on cratus for ldap work
  module Cratususer
    def cratus_connect
      options = {
        host: config.host,
        port: config.port,
        user_basedn: config.user_basedn,
        group_basedn: config.group_basedn,
        basedn: config.basedn,
        username: config.username,
        password: config.password
      }
      Cratus.config.merge(options)
      Cratus::LDAP.connect
    end

    def user_query(username)
      cratus_connect
      user = begin
        Cratus::User.new(username.to_s)
      rescue
        nil
      end
      user ? user.locked? : user
    end

    def user_groups_query(username)
      cratus_connect
      begin
        user = Cratus::User.new(username.to_s)
        raise 'NoGroups' unless user
        groups = user.member_of
        groups.map(&:name).join("\n")
      rescue
        nil
      end
    end

    def group_mem_query(groupname)
      cratus_connect
      begin
        group = Cratus::Group.new(groupname.to_s)
        raise 'InvalidGroup' unless group
        members = group.members
        members.map(&:fullname).join("\n")
      rescue
        nil
      end
    end

    def unlock_user(username)
      ldap = Cratus::LDAP.connection
      ldap.replace_attribute Cratus::User.new(username.to_s).dn, :lockouttime, '0'
    end
  end
end
