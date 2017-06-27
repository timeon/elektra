module Identity
  class UserNg < Core::ModelNG
    def test
      byebug
      begin
        api.identity.show_user_details('dsdsD').map_to(self.class)
      rescue => e
        p e.message
      end
    end
  end
end
