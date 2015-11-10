# name: Discourse Minecraft Avatar
# about: Changes the user avatars to use their Minecraft skins
# version: 1.0.0
# authors: Jacob Gillespie
# url: https://github.com/the-obsidian/discourse-minecraft-avatar

# override User avatar
class User
  MC_BASE_URI = 'https://api.mojang.com/users/profiles/minecraft'

  def minecraft_uuid
    uuid = try(:single_sign_on_record).try(:external_id)

    return uuid if uuid

    uri = "#{MC_BASE_URI}/#{username}?at=#{Time.now.to_i}"
    response = RestClient.get uri
    return false if response.code != 200

    begin
      JSON.parse(response.body)['id']
    rescue StandardError => _e
      1 # return a default
    end
  end

  def minecraft_avatar
    "https://crafatar.com/avatars/#{minecraft_uuid}?overlay=true&size={size}"
  end

  def avatar_template
    return minecraft_avatar unless uploaded_avatar_id
    hostname = RailsMultisite::ConnectionManagement.current_hostname
    UserAvatar.local_avatar_template(
      hostname, username.downcase, uploaded_avatar_id
    )
  end
end
