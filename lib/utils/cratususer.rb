module Utils
  # piggy back on cratus for ldap work
  module Cratususer
    def user_query(username)
      options = {
        host: config.host,
        port: config.port,
        user_basedn: config.user_basedn,
        basedn: config.basedn,
        username: config.username,
        password: config.password
      }
      Cratus.config.merge(options)
      Cratus::LDAP.connect
      user = begin
        Cratus::User.new(username.to_s)
      rescue
        nil
      end
      user ? user.locked? : user
    end

    def unlock_user(username)
      ldap = Cratus::LDAP.connection
      ldap.replace_attribute username.dn, :lockedtime, '0'
    end
  end
end
