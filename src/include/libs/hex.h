#include <libs/types.h>

class HEX
{
private:
public:
    static char *toString(uint64_t value, char *buffer = (char *)nullptr);
    static char *toDecimal(uint64_t value, char *buffer = (char *)nullptr);
};
