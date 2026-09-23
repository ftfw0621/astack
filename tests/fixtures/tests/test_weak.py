def test_no_assertion():
    slugify("Hello")


def test_weak_only():
    result = parse("x")
    assert result is not None
    assert result


def test_strong():
    assert slugify("Hello, World!") == "hello-world"


class TestUnit:
    def test_mock_only(self):
        store.save.assert_called_once()


def test_multiline_strong():
    assert (
        slugify("Hello, World!")
        == "hello-world"
    )


def test_multiline_weak():
    assert (
        parse("x") is not None
    )
