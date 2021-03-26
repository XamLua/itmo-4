#ifndef ____LAB2_H____
#define ____LAB2_H____

#include <linux/module.h>
#include <linux/fs.h>	
#include <linux/errno.h>	
#include <linux/types.h>	
#include <linux/fcntl.h>	
#include <linux/vmalloc.h>
#include <linux/genhd.h>
#include <linux/blkdev.h>
#include <linux/bio.h>
#include <linux/string.h>

#define MEMSIZE 0x19000 // 50*1024*1024/SECTOR_SIZE
 
#define SECTOR_SIZE 512
#define MBR_SIZE SECTOR_SIZE
#define MBR_DISK_SIGNATURE_OFFSET 440
#define MBR_DISK_SIGNATURE_SIZE 4
#define PARTITION_TABLE_OFFSET 446
#define PARTITION_ENTRY_SIZE 16 
#define PARTITION_TABLE_SIZE 64 
#define MBR_SIGNATURE_OFFSET 510
#define MBR_SIGNATURE_SIZE 2
#define MBR_SIGNATURE 0xAA55
#define BR_SIZE SECTOR_SIZE
#define BR_SIGNATURE_OFFSET 510
#define BR_SIGNATURE_SIZE 2
#define BR_SIGNATURE 0xAA55

#define BV_PAGE(bv) ((bv).bv_page)
#define BV_OFFSET(bv) ((bv).bv_offset)
#define BV_LEN(bv) ((bv).bv_len)

typedef struct
{
	unsigned char	boot_type; // 0x00 - Inactive; 0x80 - Active (Bootable)
	unsigned char	start_cyl;
	unsigned char	start_head;
	unsigned char	start_sec:6;
	unsigned char	start_cyl_hi:2;
	unsigned char	part_type;
	unsigned char	end_head;
	unsigned char	end_sec:6;
	unsigned char	end_cyl_hi:2;
	unsigned char	end_cyl;
	unsigned int	abs_start_sec;
	unsigned int	sec_in_part;
} PartEntry;
 
typedef PartEntry PartTable[4];
 
#define SEC_PER_HEAD 63
#define HEAD_PER_CYL 255
#define HEAD_SIZE (SEC_PER_HEAD * SECTOR_SIZE)
#define CYL_SIZE (SEC_PER_HEAD * HEAD_PER_CYL * SECTOR_SIZE)
 
#define sec4size(s) ((((s) % CYL_SIZE) % HEAD_SIZE) / SECTOR_SIZE)
#define head4size(s) (((s) % CYL_SIZE) / HEAD_SIZE)
#define cyl4size(s) ((s) / CYL_SIZE)
 
 
static PartTable def_part_table =
{
	{
		boot_type: 0x00,
		start_cyl: 0x0,
		start_head: 0x0,
		start_sec: 0x2,
		part_type: 0x83, // primary partition
		end_head: 0xD2,
		end_sec: 0x10,
		end_cyl: 0x3,
		abs_start_sec: 0x1,
		sec_in_part: 0xF000 // 30Mbyte
	},
	{
		boot_type: 0x00,
		start_cyl: 0x3,
		start_head: 0xD2,
		start_sec: 0x11,
		part_type: 0x05, // extended partition
		end_sec: 0x19,
		end_head: 0x5F,
		end_cyl: 0x6,
		abs_start_sec: 0xF001, 
		sec_in_part: 0x9FFF
	}
};
static unsigned int def_log_part_br_abs_start_sector[] = {0xF001, 0x14002};
static const PartTable def_log_part_table[] =
{
	{
		{   // the first mbr
			boot_type: 0x00,
			start_cyl: 0x3, 
			start_head: 0xD2,
			start_sec: 0x12, 
			part_type: 0x83,
			end_head: 0x19,
			end_sec: 0x16,
			end_cyl: 0x5,
			abs_start_sec: 0x1,
			sec_in_part: 0x5000
		},
		{	// pointer to the second mbr
			boot_type: 0x00,
			start_cyl: 0x5,
			start_head: 0x19,
			start_sec: 0x17,
			part_type: 0x05,
			end_head: 0x5F,
			end_sec: 0x19,
			end_cyl: 0x6,
			abs_start_sec: 0x5001,
			sec_in_part: 0x4FFE
		}
	},
	{
		{	// the second mbr
			boot_type: 0x00,
			start_cyl: 0x5,
			start_head: 0x19,
			start_sec: 0x18,
			part_type: 0x83,
			end_head: 0x5F,
			end_sec: 0x19,
			end_cyl: 0x6,
			abs_start_sec: 0x1,
			sec_in_part: 0x4FFD
		}
	}
};

#endif 