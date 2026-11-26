class_name PixelArt
extends RefCounted
## Small original pixel sprites, made from rectangles rather than external art.

static func _rect(image: Image, x: int, y: int, w: int, h: int, color: String) -> void:
	image.fill_rect(Rect2i(x, y, w, h), Color(color))

static func car(paint: Color, is_player: bool = false) -> Texture2D:
	var image: Image = Image.create(56, 40, false, Image.FORMAT_RGBA8)
	var body: String = paint.to_html(false)
	_rect(image, 5, 36, 46, 4, "20253288")
	_rect(image, 7, 24, 6, 14, "141c2b")
	_rect(image, 43, 24, 6, 14, "141c2b")
	_rect(image, 12, 1, 32, 3, "141c2b")
	_rect(image, 8, 4, 40, 24, "141c2b")
	_rect(image, 4, 19, 48, 17, "141c2b")
	_rect(image, 11, 4, 34, 22, body)
	_rect(image, 7, 21, 42, 12, body)
	_rect(image, 15, 7, 26, 12, "18263d")
	_rect(image, 17, 8, 22, 3, "344963")
	_rect(image, 16, 15, 24, 2, "263b52")
	_rect(image, 1, 17, 6, 5, "141c2b")
	_rect(image, 49, 17, 6, 5, "141c2b")
	_rect(image, 2, 18, 4, 2, body)
	_rect(image, 50, 18, 4, 2, body)
	_rect(image, 8, 24, 40, 6, "192132")
	for x in [10, 17, 34, 41]:
		_rect(image, x, 25, 5, 3, "ff633e")
	_rect(image, 10, 31, 36, 2, body)
	_rect(image, 22, 30, 12, 3, "8c9aa5")
	_rect(image, 13, 34, 30, 2, "273146")
	if is_player:
		_rect(image, 18, 35, 5, 3, "a0adb6")
		_rect(image, 33, 35, 5, 3, "a0adb6")
		_rect(image, 19, 36, 3, 2, "141c2b")
		_rect(image, 34, 36, 3, 2, "141c2b")
	return ImageTexture.create_from_image(image)

static func barrier() -> Texture2D:
	var image: Image = Image.create(50, 26, false, Image.FORMAT_RGBA8)
	_rect(image, 2, 23, 46, 3, "20253288")
	_rect(image, 5, 14, 5, 10, "202b40")
	_rect(image, 40, 14, 5, 10, "202b40")
	_rect(image, 1, 1, 48, 18, "182234")
	_rect(image, 3, 3, 44, 14, "e95746")
	for y in range(3, 17):
		for x in range(3, 47):
			if posmod(x + y, 18) < 7:
				image.set_pixel(x, y, Color("f7edd0"))
	_rect(image, 4, 21, 9, 3, "344359")
	_rect(image, 37, 21, 9, 3, "344359")
	return ImageTexture.create_from_image(image)

static func rock() -> Texture2D:
	var image: Image = Image.create(34, 27, false, Image.FORMAT_RGBA8)
	_rect(image, 0, 24, 34, 3, "20253288")
	_rect(image, 2, 17, 30, 8, "563e39")
	_rect(image, 6, 8, 24, 15, "563e39")
	_rect(image, 11, 2, 14, 21, "563e39")
	_rect(image, 8, 11, 19, 11, "a76c42")
	_rect(image, 13, 4, 10, 16, "c28b53")
	_rect(image, 5, 19, 8, 4, "8a563b")
	_rect(image, 17, 16, 10, 7, "915c3c")
	_rect(image, 13, 6, 5, 5, "e0a668")
	_rect(image, 25, 17, 5, 5, "704b3a")
	return ImageTexture.create_from_image(image)
