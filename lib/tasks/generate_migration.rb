namespace :taggable do
    desc 'Creates the database migration needed for acts_as_as_taggable_on_padrino'
    task :create_migration => :environment do
      filename = "create_taggable_tables"

      def return_last_migration_number
        Dir[Dir.pwd + '/db/migrate/*.rb'].map { |f|
          File.basename(f).match(/^(\d+)/)[0].to_i
        }.max.to_i || 0
      end

      if (Dir[Dir.pwd + "/db/migrate/*_#{filename.underscore}.rb"].size > 0)
        puts "\e[31mMigration already exists\e[0m"
      elsif
        migration_filename = "#{format("%03d", return_last_migration_number() +1)}_#{filename.underscore}.rb"
        puts "Creating: \e[32m#{migration_filename}\e[0m"
        FileUtils.cp(File.dirname(__FILE__) + "/templates/migration.rb", Dir.pwd + "/db/migrate/" + migration_filename)
        puts "Now run: \e[32mpadrino rake ar:migrate\e[0m"
      end


    end
end