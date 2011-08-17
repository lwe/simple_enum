def fill_db(options={}) 
  options = { :fill => true, :genders => false }.merge(options)

  if options[:fill]
    # fill db with some rows
    Dummy.create({ :name => 'Anna',  :gender_cd => 1, :word_cd => 'alpha', :other => 0})
    Dummy.create({ :name => 'Bella', :gender_cd => 1, :word_cd => 'beta', :other => 1})
    Dummy.create({ :name => 'Chris', :gender_cd => 0, :word_cd => 'gamma', :other => 2})
  end

  if options[:genders]    
    male = Gender.new({ :name => 'male' })
    male.id = 0;
    male.save!

    female = Gender.new({ :name => 'female' })
    female.id = 1;
    female.save!
  end
end