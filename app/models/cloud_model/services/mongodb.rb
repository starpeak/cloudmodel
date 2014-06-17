module CloudModel
  module Services
    class Mongodb < Base
      field :port, type: Integer, default: 27017
      
      def kind
        :mongodb
      end
      
      def backupable?
        true 
      end
      
      def backup
        return false unless has_backups
        timestamp = Time.now.strftime "%Y%m%d%H%M%S"
        FileUtils.mkdir_p backup_directory
        command = "mongodump -h #{guest.private_address} --port #{port} -o #{backup_directory}/#{timestamp}"

        Rails.logger.debug command
        Rails.logger.debug `#{command}`
        
        if $?.success? and File.exists? "#{backup_directory}/#{timestamp}"
          FileUtils.rm_f "#{backup_directory}/latest"
          FileUtils.ln_s "#{backup_directory}/#{timestamp}", "#{backup_directory}/latest"
          cleanup_backups
          
          return true
        else
          FileUtils.rm_rf "#{backup_directory}/#{timestamp}"
          return false
        end
      end
      
      def restore timestamp='latest'
        if File.exists? "#{backup_directory}/#{timestamp}"
          command = "mongorestore --drop -h #{guest.private_address} --port #{port} #{backup_directory}/#{timestamp}"

          Rails.logger.debug command
          Rails.logger.debug `#{command}`

          return $?.success?
        else
          return false
        end
      end
    end
  end
end