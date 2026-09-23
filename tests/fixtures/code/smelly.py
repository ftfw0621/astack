from typing import cast


def load(raw):
    user = cast(User, raw)  # type: ignore
    try:
        save(user)
    except Exception:
        pass
    # print(user)
    return user
