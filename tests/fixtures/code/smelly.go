package smelly

func Load(raw interface{}) error {
	user := raw.(User)
	_ = err
	//nolint:errcheck
	save(user)
	return nil
}
