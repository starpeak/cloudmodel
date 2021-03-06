namespace :cloudmodel do
  desc "Backup marked services and volumes"
  task :backup do
    CloudModel::Guest.all.map{|guest| guest.backup}
  end
  
  namespace :host_image do
    task :load_host do
      @host_worker = CloudModel::Images::HostWorker.new CloudModel::Host.find(ENV['HOST_ID'])
    end
    
    desc "Build host image"
    task :build_image => [:environment, :load_host] do
      @host_worker.build_image
    end
  end
  
  namespace :host do
    task :load_host do
      @host_worker = CloudModel::HostWorker.new CloudModel::Host.find(ENV['HOST_ID'])
    end
    
    desc "Deploy host"
    task :deploy => [:environment, :load_host] do
      @host_worker.deploy
    end
    
    desc "Redeploy host"
    task :redeploy => [:environment, :load_host] do
      @host_worker.redeploy
    end
        
    desc "Update tinc host files"
    task :update_tinc_host_files => [:environment, :load_host] do
      @host_worker.update_tinc_host_files
    end
  end
  
  namespace :guest_image do
    task :load_host do
      @host_worker = CloudModel::Images::GuestWorker.new CloudModel::Guest.find(ENV['GUEST_ID'])
    end
    
    desc "Build host image"
    task :build_image => [:environment, :load_host] do
      @host_worker.build_image
    end
  end
  
  namespace :guest do
    task :load_guest do
      @guest_worker = CloudModel::GuestWorker.new CloudModel::Guest.find(ENV['GUEST_ID'])
    end
    
    desc "Deploy guest with id given as guest_id"
    task :deploy => [:environment, :load_guest] do
      @guest_worker.deploy
    end    
    
    desc "Redeploy guest with id given as guest_id"
    task :redeploy => [:environment, :load_guest] do
      @guest_worker.redeploy
    end
    
    desc "Redeploy many guest with ids given as guest_ids"
    task :redeploy_many => [:environment] do
      guests_by_hosts = {}
      ids = ENV['GUEST_IDS'].split('\ ')
      
      CloudModel::Guest.where(:id.in => ids).to_a.each do |guest|
        if guest.deploy_state == :pending
          guests_by_hosts[guest.host_id] ||= []
          guests_by_hosts[guest.host_id] << guest
        end
      end
      
      guests_by_hosts.each do |host_id, guests|
        # TODO: Multithread redeploy (thread per host)
        puts "** Deploy on Host #{host_id}"
        guests.each do |guest|
          puts "=> Redeploy Guest '#{guest.name}'"
          @guest_worker = CloudModel::GuestWorker.new guest
          @guest_worker.redeploy
        end
      end
    end
    
    desc "Backup guest"
    task :backup => [:environment, :load_guest] do
      @guest.backup
    end
    
    # Perfect for call by crontab
    # bash -c 'cd /var/www/rails/current && RAILS_ENV=production /usr/local/bin/bundle exec rake cloudmodel:guest:backup_all'
    desc "Backup all guest"
    task :backup_all => [:environment] do
      CloudModel::Guest.all.each do |guest|
        guest.backup
      end
    end    
    
    desc "Build guest image"
    task :build_image => [:environment, :load_guest] do
      @guest_worker.build_image
    end
  end
  
  namespace :web_image do
    task :load_web_image do
      @web_image_worker = CloudModel::WebImageWorker.new CloudModel::WebImage.find(ENV['WEB_IMAGE_ID'])
    end
    
    desc "Build WebImage"
    task :build => [:environment, :load_web_image] do
      @web_image_worker.build
    end
  end
  
end