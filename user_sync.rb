module ProjectDirectory

  module MailChimp

    class UserSync

      def self.sync
        api = "YOUR API KEY HERE"
        list_id = "YOUR LIST ID HERE"

        h = Hominid::API.new(api)

        User.all.each do |user|
          userid = user.id
          currentInfo = h.listMemberInfo(list_id, [user.email]) 
          #if email not on mailing list, adds it to mailing list
          if (currentInfo["success"] == 0) then
            begin
              h.listSubscribe(list_id, user.email, {:USER_ID => userid}, 'html', false, true, true, false)
            rescue Hominid::APIError => e
              puts "Error on #{user.email} (#{userid}): #{e}"
           end
          end
        end


        #temp/toDelete contains all email addresses in mailchimp
        temp = h.listMembers(list_id, 'subscribed')
        toDelete = temp["data"]
        i = 0
        length = toDelete.length

        #goes through every possible email address & unsubscribes it from
        #mailchimp if it is not found in the user.find_by_email call
        while (i < length)
          toDelete = temp["data"]
          #gets i-th element in array toDelete
          toDelete = toDelete[i]
          i = i + 1
          #gets email field from toDelete
          email = toDelete["email"]
          if (User.find_by_email(email) == nil) then
            puts "this email address is going to be deleted: " + email
            h.listUnsubscribe(list_id, email, true, false, false)
          end
        end

      end

    end

  end

end

