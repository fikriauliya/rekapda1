desc "This task is called by the Heroku scheduler add-on"
task :fetch_data => :environment do
  puts "Update..."
  puts "Done.."
end