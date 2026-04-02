ODIR = obj
SDIR = src
BDIR = bin
IDIR = include

OBJ_PLINGUA = y.tab.o lex.yy.o node_value.o scope.o syntax_tree.o system.o init.o parser.o pattern.o formats.o cplusplus.o 

OBJ_PSIM = psim.o command_line.o
      
BIN_PLINGUA = plingua

BIN_PSIM = psim

CFlags=-c -O3 -Wall -std=gnu++11 
LDFlags=-lfl -lboost_system -lboost_filesystem -lboost_program_options
CC=g++
RM=rm
FLEX=flex
BISON=bison

all: grammar compiler simulator extensions

grammar: $(SDIR)/parser/y.tab.c $(SDIR)/parser/lex.yy.c

compiler: $(patsubst %,$(ODIR)/%,$(OBJ_PLINGUA)) $(BIN_PLINGUA)

simulator: $(patsubst %,$(ODIR)/%,$(OBJ_PSIM)) $(BIN_PSIM)

# Example use case
example_foraging: examples/adaptive_foraging.cpp
	@mkdir -p $(BDIR)
	$(CC) -O3 -Wall -std=gnu++11 -I$(IDIR) -o $(BDIR)/adaptive_foraging $<

# RR extension demos and tests
extensions: example_foraging $(BDIR)/rr_simple_demo $(BDIR)/rr_demo $(BDIR)/demo_repl $(BDIR)/test_rr_enhanced $(BDIR)/test_next_directions

$(BDIR)/rr_simple_demo: examples/rr_simple_demo.cpp
	@mkdir -p $(BDIR)
	$(CC) -O3 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

$(BDIR)/rr_demo: examples/rr_demo.cpp
	@mkdir -p $(BDIR)
	$(CC) -O3 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

$(BDIR)/demo_repl: demo_repl.cpp
	@mkdir -p $(BDIR)
	$(CC) -O2 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

$(BDIR)/test_rr_enhanced: test_rr_enhanced.cpp
	@mkdir -p $(BDIR)
	$(CC) -O2 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

$(BDIR)/test_next_directions: test_next_directions.cpp
	@mkdir -p $(BDIR)
	$(CC) -O2 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

reading_example: examples/reading_example.cpp
	@mkdir -p $(BDIR)
	$(CC) -O3 -Wall -std=gnu++11 -I$(IDIR) -I/usr/local/include -o $(BDIR)/reading_example $<

test_extensions: $(BDIR)/test_rr_enhanced $(BDIR)/test_next_directions
	@echo "Running RR extension tests..."
	$(BDIR)/test_rr_enhanced
	$(BDIR)/test_next_directions
	@echo "All extension tests passed."

$(BIN_PLINGUA): $(patsubst %,$(ODIR)/%,$(OBJ_PLINGUA))
	@mkdir -p $(BDIR)
	$(CC) $^ $(LDFlags) -o $(BDIR)/$@ 
	
$(BIN_PSIM): $(patsubst %,$(ODIR)/%,$(OBJ_PSIM))
	@mkdir -p $(BDIR)
	$(CC) $^ $(LDFlags) -o $(BDIR)/$@ 	

$(ODIR)/%.o: $(SDIR)/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $@ $<

$(ODIR)/%.o: $(SDIR)/psystem/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $@ $<

$(ODIR)/%.o: $(SDIR)/parser/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $@ $<

$(ODIR)/%.o: $(SDIR)/simulator/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $@ $<


$(ODIR)/%.o: $(SDIR)/simulator/psim/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $@ $<

$(ODIR)/%.o: $(SDIR)/generators/cplusplus/%.cpp	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $@ $<

$(ODIR)/%.o: $(SDIR)/parser/%.c	
	@mkdir -p $(ODIR)
	$(CC) $(CFlags) -I$(IDIR) -o $@ $<

$(SDIR)/parser/y.tab.c: $(SDIR)/parser/plingua.y
	$(BISON) -o $@ -yd $<

$(SDIR)/parser/lex.yy.c: $(SDIR)/parser/plingua.l
	$(FLEX) -o $@ $<  
	
clean:
	$(RM) -f $(patsubst %,$(ODIR)/%,$(OBJ_PLINGUA)) $(patsubst %,$(ODIR)/%,$(OBJ_PSIM)) \
	  $(BDIR)/$(BIN_PLINGUA) $(BDIR)/$(BIN_PSIM) \
	  $(BDIR)/adaptive_foraging $(BDIR)/rr_simple_demo $(BDIR)/rr_demo \
	  $(BDIR)/demo_repl $(BDIR)/test_rr_enhanced $(BDIR)/test_next_directions \
	  $(BDIR)/reading_example $(BDIR)/test_e2e \
	  $(SDIR)/parser/y.tab.c $(SDIR)/parser/y.tab.h $(SDIR)/parser/lex.yy.c
	
check: compiler
	@echo "Running P-Lingua compiler checks..."
	$(BDIR)/$(BIN_PLINGUA) examples/transition.pli -o $(ODIR)/test_check.bin
	$(BDIR)/$(BIN_PLINGUA) examples/sat_cell_division0.pli -o $(ODIR)/test_check2.bin
	@echo "All checks passed."

test: $(BDIR)/test_e2e
	@echo "Running e2e unit tests..."
	$(BDIR)/test_e2e
	@echo "All e2e tests passed."

$(BDIR)/test_e2e: test_e2e.cpp
	@mkdir -p $(BDIR)
	$(CC) -O2 -Wall -std=gnu++11 -I$(IDIR) -o $@ $<

install:
	@mkdir -p /usr/local/PLingua/$(BIN_PLINGUA)/
	@mkdir -p /usr/local/PLingua/$(BIN_PSIM)/
	@cp $(BDIR)/$(BIN_PLINGUA) /usr/local/PLingua/$(BIN_PLINGUA)/
	@cp $(BDIR)/$(BIN_PSIM) /usr/local/PLingua/$(BIN_PSIM)/
	@cp LICENSE /usr/local/PLingua/
	@ln -sf /usr/local/PLingua/$(BIN_PLINGUA)/$(BIN_PLINGUA) /usr/local/bin/
	@ln -sf /usr/local/PLingua/$(BIN_PSIM)/$(BIN_PSIM) /usr/local/bin/
	@cp -rf $(IDIR)/cereal/ /usr/local/include/
	@mkdir -p /usr/local/include/plingua/
	@cp -f $(IDIR)/serialization.* /usr/local/include/plingua/
	
