module Identity
  class UserNg < Core::ModelNG
    def test
      byebug
      begin
        api.compute.list_images
        api.identity.show_user_details('d799b4c2b43df2192ee6c4437879523d857e0220977ed8674056b504dbafc884').map_to(self.class)
      rescue => e
        p e.message
      end
    end
  end
end
