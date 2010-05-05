
typedef struct {
    float min;
    float max;
} TsunamiRange;

TsunamiRange *get_stats(char *path, short sample_count);
