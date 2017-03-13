namespace :leihs do
  namespace :files do
    desc 'Tar archive attachments and images'
    task :tar do
      files_paths = ['public/attachments/',
                     'public/images/',
                     'public/system/']
      tar_filepath = '/tmp/leihs-files.tar.gz'
      tar = "tar -czvhf #{tar_filepath} #{files_paths.join(' ')}"
      unless system(tar)
        raise 'Creating tar archive failed!'
      end
    end
  end
end
