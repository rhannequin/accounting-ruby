admin = User.create(
  name: 'rhannequin',
  email: 'hello@rhannequ.in',
  password: 'password'
)

admin.add_role(:admin)
