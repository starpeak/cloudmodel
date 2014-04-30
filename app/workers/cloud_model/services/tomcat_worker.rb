require 'stringio'

module CloudModel
  module Services
    class TomcatWorker < CloudModel::Services::BaseWorker
      def write_config
        target = File.expand_path("/var/tomcat", @guest.deploy_path) 
              
        Rails.logger.debug "    Deploy WAR Image #{@model.deploy_war_image.name} to #{@guest.deploy_path}#{target}"
        io = StringIO.new( @model.deploy_war_image.file.data)
        #@host.ssh_connection.sftp.upload!(io, "/tmp/temp.tar")
              
        @host.exec "mkdir -p #{target.shellescape}/data && cd #{target.shellescape} && tar xjpf /tmp/temp.tar"
            
        # Read manifest
        manifest = ''
        @host.ssh_connection.sftp.file.open( "#{target}/manifest.yml") do |f|
          manifest = YAML.load(f.read)
        end
        
        Rails.logger.debug "    Write tomcat config"
        @host.ssh_connection.sftp.file.open(File.expand_path("etc/tomcat-7/server.xml", @guest.deploy_path), 'w') do |f|
          f.write render("/cloud_model/guest/etc/tomcat-7/server.xml", guest: @guest, model: @model)
        end
              
        @host.ssh_connection.sftp.file.open(File.expand_path("etc/conf.d/tomcat-7", @guest.deploy_path), 'w') do |f|
          f.write render("/cloud_model/guest/etc/conf.d/tomcat-7", manifest: manifest, worker: self, guest: @guest, model: @model)
        end
              
        @host.ssh_connection.sftp.file.open(File.expand_path("etc/tomcat-7/Catalina/localhost/ROOT.xml", @guest.deploy_path), 'w') do |f|
          f.write render("/cloud_model/guest/etc/tomcat-7/servlet.xml", manifest: manifest, worker: self, guest: @guest, model: @model)
        end
              
        @host.exec "chown -R 265:265 #{target}"
      end
    
      def interpolate_value(value)
        value.to_s.gsub("%TARGET%", "/var/tomcat").gsub("%DATA_DIR%", "/var/tomcat/data")
      end
    
      def auto_start
        Rails.logger.debug "    Add Tomcat to runlevel default"
        @host.exec "ln -sf /etc/init.d/tomcat-7 #{@guest.deploy_path}/etc/runlevels/default/"
      end
    end
  end
end