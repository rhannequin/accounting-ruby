me = User.create!(
  name: 'rhannequin',
  email: 'hello@rhannequ.in',
  password: 'password'
)

me.add_role(:admin)

User.create!(
  name: 'zuzu',
  email: 'her@rhannequ.in',
  password: 'password'
)
