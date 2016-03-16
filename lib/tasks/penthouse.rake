require 'penthouse/migrator'

penthouse_namespace = namespace :penthouse do

  desc "Migrate all tenants to latest version"
  task :migrate do
    warn_if_tenants_empty

    version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil

    tenant_identifiers.each do |tenant_identifier|
      begin
        puts("Migrating #{tenant_identifier || '***global***'} tenant")
        Penthouse::Migrator.migrate(tenant_identifier, version)
      rescue Penthouse::TenantNotFound => e
        puts e.message
      end
    end
  end

  desc "Rolls the migration back to the previous version (specify steps w/ STEP=n) across all tenants."
  task :rollback do
    warn_if_tenants_empty

    step = ENV['STEP'] ? ENV['STEP'].to_i : 1

    tenant_identifiers.each do |tenant_identifier|
      begin
        puts("Rolling back #{tenant_identifier || '***global***'} tenant")
        Penthouse::Migrator.rollback(tenant_identifier, step)
      rescue Penthouse::TenantNotFound => e
        puts e.message
      end
    end
  end

  namespace :migrate do
    desc 'Runs the "up" for a given migration VERSION across all tenants.'
    task :up do
      warn_if_tenants_empty

      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      tenant_identifiers.each do |tenant_identifier|
        begin
          puts("Migrating #{tenant_identifier || '***global***'} tenant up")
          Penthouse::Migrator.run(:up, tenant_identifier, version)
        rescue Penthouse::TenantNotFound => e
          puts e.message
        end
      end
    end

    desc 'Runs the "down" for a given migration VERSION across all tenants.'
    task :down do
      warn_if_tenants_empty

      version = ENV['VERSION'] ? ENV['VERSION'].to_i : nil
      raise 'VERSION is required' unless version

      tenant_identifiers.each do |tenant_identifier|
        begin
          puts("Migrating #{tenant_identifier || '***global***'} tenant down")
          Penthouse::Migrator.run(:down, tenant_identifier, version)
        rescue Penthouse::TenantNotFound => e
          puts e.message
        end
      end
    end

    desc 'Rolls back the tenant one migration and re-migrate up (options: STEP=x, VERSION=x).'
    task :redo do
      if ENV['VERSION']
        penthouse_namespace['migrate:down'].invoke
        penthouse_namespace['migrate:up'].invoke
      else
        penthouse_namespace['rollback'].invoke
        penthouse_namespace['migrate'].invoke
      end
    end
  end

  def tenant_identifiers
    if (t = ENV["tenant"] || ENV["tenants"])
      t.split(",").map(&:strip)
    else
      Penthouse.tenant_identifiers
    end
  end

  def warn_if_tenants_empty
    if tenant_identifiers.empty?
      puts <<-WARNING
        [WARNING] - The list of tenants to migrate appears to be empty. This could mean you've not created any.
        Note that your tenants currently haven't been migrated. You'll need to run `db:migrate` to rectify this.
      WARNING
    end
  end
end
