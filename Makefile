PRGNAME     = handy
CC			= gcc
CXX			= g++

PORT = rs90
SOUND_OUTPUT = alsa
PROFILE = 0

SRCDIR		= ./src/ ./src/gui/ ./src/handy-libretro src/ports ./src/ports/input/sdl src/sdlemu ./src/unzip
VPATH		= $(SRCDIR)
SRC_C		= $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.c))
SRC_CP		= $(foreach dir, $(SRCDIR), $(wildcard $(dir)/*.cpp))
OBJ_C		= $(notdir $(patsubst %.c, %.o, $(SRC_C)))
OBJ_CP		= $(notdir $(patsubst %.cpp, %.o, $(SRC_CP)))
OBJS		= $(OBJ_C) $(OBJ_CP)

CFLAGS		= -O0 -g -fpermissive
CFLAGS		+= -DWANT_CRC32 -DANSI_GCC -DSDL_PATCH -D$(PORT)
CFLAGS		+= -I./src -I./src/handy-libretro -I./src/sdlemu -Isrc/ports -Isrc/ports/sound -Isrc/ports/sound -Isrc/ports/input/sdl

ifeq ($(PORT), rs90)
CFLAGS 		+= -DRS90
else ifeq  ($(PORT), rs97)
CFLAGS 		+= -DRS97
else ifeq  ($(PORT), retrostone)
CFLAGS 		+= -DRETROSTONE
endif

SRCDIR		+= ./src/ports/graphics/$(PORT)

ifeq ($(SOUND_OUTPUT), alsa)
SRCDIR		+= ./src/ports/sound/alsa
else ifeq ($(SOUND_OUTPUT), oss)
SRCDIR		+= ./src/ports/sound/oss
else ifeq ($(SOUND_OUTPUT), portaudio)
SRCDIR		+= ./src/ports/sound/portaudio
else ifeq ($(SOUND_OUTPUT), libao)
SRCDIR		+= ./src/ports/sound/libao
endif

ifeq ($(PROFILE), YES)
CFLAGS 		+= -fprofile-generate=/home/retrofw/profile
else ifeq ($(PROFILE), APPLY)
CFLAGS		+= -fprofile-use -fbranch-probabilities
endif

CXXFLAGS	= $(CFLAGS)
LDFLAGS     = -nodefaultlibs -lc -lstdc++ -lgcc -lgcc_s -lm -lSDL -lz -no-pie -Wl,--as-needed -Wl,--gc-sections -s -flto

ifeq ($(SOUND_OUTPUT), portaudio)
LDFLAGS		+= -lportaudio
endif
ifeq ($(SOUND_OUTPUT), libao)
LDFLAGS		+= -lao
endif
ifeq ($(SOUND_OUTPUT), alsa)
LDFLAGS		+= -lasound
endif

# Rules to make executable
$(PRGNAME): $(OBJS)  
	$(CC) $(CFLAGS) -o $(PRGNAME) $^ $(LDFLAGS)

$(OBJ_C) : %.o : %.c
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJ_CP) : %.o : %.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

clean:
	rm -f $(PRGNAME) *.o
