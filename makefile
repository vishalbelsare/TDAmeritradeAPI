
PROJECT_ROOT := $(strip $(patsubst %/, %, $(dir $(abspath $(lastword $(MAKEFILE_LIST))))))
BUILD_DIR := $(PROJECT_ROOT)/build
DEBUG_BUILD_DIR := $(BUILD_DIR)/debug
RELEASE_BUILD_DIR := $(BUILD_DIR)/release


### TDAmeritradeAPI.so ###

TDMA_LIB_DEBUG_BUILD_DIR := $(DEBUG_BUILD_DIR)
TDMA_LIB_RELEASE_BUILD_DIR := $(RELEASE_BUILD_DIR)

TDMA_LIB_SRC_DIRS := src \
src/execute \
src/get \
src/streaming \
uWebSockets

TDMA_LIB_DEBUG_SUBDIRS = $(addprefix $(TDMA_LIB_DEBUG_BUILD_DIR)/, $(TDMA_LIB_SRC_DIRS))
TDMA_LIB_RELEASE_SUBDIRS = $(addprefix $(TDMA_LIB_RELEASE_BUILD_DIR)/, $(TDMA_LIB_SRC_DIRS))

TDMA_LIB_OBJS = $(foreach var, $(TDMA_LIB_SRC_DIRS), $(patsubst %.cpp, %.o, $(wildcard $(var)/*.cpp)) ) 
TDMA_LIB_DEBUG_OBJS = $(addprefix $(TDMA_LIB_DEBUG_BUILD_DIR)/, $(TDMA_LIB_OBJS))
TDMA_LIB_RELEASE_OBJS = $(addprefix $(TDMA_LIB_RELEASE_BUILD_DIR)/, $(TDMA_LIB_OBJS))

TDMA_LIB_DEBUG_DEPS = $(patsubst %.o, %.d, $(TDMA_LIB_DEBUG_OBJS)) 
TDMA_LIB_RELEASE_DEPS = $(patsubst %.o, %.d, $(TDMA_LIB_RELEASE_OBJS))

TDMA_LIB_LIBS := -lssl -lcrypto -lz -lcurl -lpthread -lutil -ldl
ifeq ($(UNAME), Darwin)
TDMA_LIB_LIBS += -luv
endif


### TDAmeritradeAPI_CPP_Test ###

CPP_TEST_SRC_BASEDIR := test/cpp

CPP_TEST_DEBUG_BUILD_DIR := $(DEBUG_BUILD_DIR)/$(CPP_TEST_SRC_BASEDIR)
CPP_TEST_RELEASE_BUILD_DIR := $(RELEASE_BUILD_DIR)/$(CPP_TEST_SRC_BASEDIR)

CPP_TEST_SRC_DIRS := .

CPP_TEST_DEBUG_SUBDIRS := $(patsubst %/., %, $(addprefix $(CPP_TEST_DEBUG_BUILD_DIR)/, $(CPP_TEST_SRC_DIRS)) )
CPP_TEST_RELEASE_SUBDIRS := $(patsubst %/., %, $(addprefix $(CPP_TEST_RELEASE_BUILD_DIR)/, $(CPP_TEST_SRC_DIRS)) )

CPP_TEST_OBJS := $(foreach var, $(addprefix test/cpp/, $(CPP_TEST_SRC_DIRS)), $(patsubst test/cpp/./%.cpp, %.o, $(wildcard $(var)/*.cpp)) ) 

CPP_TEST_DEBUG_OBJS := $(addprefix $(CPP_TEST_DEBUG_BUILD_DIR)/, $(CPP_TEST_OBJS))
CPP_TEST_RELEASE_OBJS := $(addprefix $(CPP_TEST_RELEASE_BUILD_DIR)/, $(CPP_TEST_OBJS))

CPP_TEST_DEBUG_DEPS = $(patsubst %.o, %.d, $(CPP_TEST_DEBUG_OBJS)) 
CPP_TEST_RELEASE_DEPS = $(patsubst %.o, %.d, $(CPP_TEST_RELEASE_OBJS))

CPP_TEST_LIBS := -lTDAmeritradeAPI

SHARED_FLAGS := -std=c++11 -Wall -fmessage-length=0 
TDMA_LIB_FLAGS := $(SHARED_FLAGS) -DTHIS_EXPORTS_INTERFACE


all: debug release test-cpp-debug test-cpp-release


debug: $(DEBUG_BUILD_DIR)/libTDAmeritradeAPI.so

$(DEBUG_BUILD_DIR)/libTDAmeritradeAPI.so: $(TDMA_LIB_DEBUG_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C++ Linker'
	g++ -shared -o $(DEBUG_BUILD_DIR)/libTDAmeritradeAPI.so $(TDMA_LIB_DEBUG_OBJS) $(TDMA_LIB_LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

$(TDMA_LIB_DEBUG_BUILD_DIR)/%.o : $(PROJECT_ROOT)/%.cpp | $(TDMA_LIB_DEBUG_SUBDIRS)
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ $(TDMA_LIB_FLAGS) -O0 -g3 -c -DDEBUG -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

$(TDMA_LIB_DEBUG_SUBDIRS):	
	mkdir -p $@

-include $(TDMA_LIB_DEBUG_DEPS)


release: $(RELEASE_BUILD_DIR)/libTDAmeritradeAPI.so

$(RELEASE_BUILD_DIR)/libTDAmeritradeAPI.so: $(TDMA_LIB_RELEASE_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C++ Linker'
	g++ -shared -o $(RELEASE_BUILD_DIR)/libTDAmeritradeAPI.so $(TDMA_LIB_RELEASE_OBJS) $(TDMA_LIB_LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

$(TDMA_LIB_RELEASE_BUILD_DIR)/%.o : $(PROJECT_ROOT)/%.cpp | $(TDMA_LIB_RELEASE_SUBDIRS)
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ $(TDMA_LIB_FLAGS) -O3 -c -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

$(TDMA_LIB_RELEASE_SUBDIRS):	
	mkdir -p $@	
	
-include $(TDMA_LIB_RELEASE_DEPS)
	

test-cpp-debug: $(DEBUG_BUILD_DIR)/TDAmeritradeAPI_CPP_Test

$(DEBUG_BUILD_DIR)/TDAmeritradeAPI_CPP_Test: $(DEBUG_BUILD_DIR)/libTDAmeritradeAPI.so $(CPP_TEST_DEBUG_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C++ Linker'
	g++ -L"$(DEBUG_BUILD_DIR)" -Wl,-rpath,"$(DEBUG_BUILD_DIR)" -o $(DEBUG_BUILD_DIR)/TDAmeritradeAPI_CPP_Test $(CPP_TEST_DEBUG_OBJS) $(CPP_TEST_LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

$(CPP_TEST_DEBUG_BUILD_DIR)/%.o : $(CPP_TEST_SRC_BASEDIR)/%.cpp | $(CPP_TEST_DEBUG_SUBDIRS)
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I"$(PROJECT_ROOT)/include" $(SHARED_FLAGS) -O0 -g3 -c -DDEBUG -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

$(CPP_TEST_DEBUG_SUBDIRS):	
	mkdir -p $@

-include $(CPP_TEST_DEBUG_DEPS)


test-cpp-release: $(RELEASE_BUILD_DIR)/TDAmeritradeAPI_CPP_Test

$(RELEASE_BUILD_DIR)/TDAmeritradeAPI_CPP_Test: $(RELEASE_BUILD_DIR)/libTDAmeritradeAPI.so $(CPP_TEST_RELEASE_OBJS)
	@echo 'Building target: $@'
	@echo 'Invoking: GCC C++ Linker'
	g++ -L"$(RELEASE_BUILD_DIR)" -Wl,-rpath,"$(RELEASE_BUILD_DIR)" -o $(RELEASE_BUILD_DIR)/TDAmeritradeAPI_CPP_Test $(CPP_TEST_RELEASE_OBJS) $(CPP_TEST_LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

$(CPP_TEST_RELEASE_BUILD_DIR)/%.o : $(CPP_TEST_SRC_BASEDIR)/%.cpp | $(CPP_TEST_RELEASE_SUBDIRS)
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C++ Compiler'
	g++ -I"$(PROJECT_ROOT)/include" $(SHARED_FLAGS) -O3 -c -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

$(CPP_TEST_RELEASE_SUBDIRS):	
	mkdir -p $@

-include $(CPP_TEST_RELEASE_DEPS)



clean: clean-debug clean-release clean-tests

clean-debug:
	rm -fr $(DEBUG_BUILD_DIR)/libTDAmeritradeAPI.so $(TDMA_LIB_DEBUG_SUBDIRS)
	
clean-release:
	rm -fr $(RELEASE_BUILD_DIR)/libTDAmeritradeAPI.so $(TDMA_LIB_RELEASE_SUBDIRS)

clean-tests:
	rm -fr $(DEBUG_BUILD_DIR)/TDAmeritradeAPI_CPP_Test $(DEBUG_BUILD_DIR)/test \
	$(RELEASE_BUILD_DIR)/TDAmeritradeAPI_CPP_Test $(RELEASE_BUILD_DIR)/test


.PHONY : all debug release test-cpp-debug test-cpp-release clean clean-debug clean-release clean-tests


