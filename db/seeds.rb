me = User.create(
  name: 'rhannequin',
  email: 'hello@rhannequ.in',
  password: 'password'
)

me.add_role(:admin)

her = User.create(
  name: 'zuzu',
  email: 'her@rhannequ.in',
  password: 'password'
)
