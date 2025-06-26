from PIL import Image
im = Image.open('mew.bmp')

# print in ascii
# for i in range(0, im.size[0]):
#   for j in range(0, im.size[1]):
#     print(' ' if im.getpixel((j, i)) == (0, 0, 0, 255) else 'X', end='')
#   print()


def convert_8_pixels(im, i, j):
  return hex(int(''.join(['0' if im.getpixel((j, c)) == (0, 0, 0, 255) else '1' for c in reversed(range(i, i + 8))]), 2))


margin = ['0'] * (128 - im.size[0]) // 2
for i in range(0, im.size[0], 8):
  print(','.join(margin + [convert_8_pixels(im, i, j)
        for j in range(0, im.size[1])] + margin), end=',')
