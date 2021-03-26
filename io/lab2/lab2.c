#include "lab2.h"

int c = 0; //Variable for Major Number

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Davidov Ivan, Nikita Shishkin P3400");
MODULE_DESCRIPTION("LAB2 - BLOCK DRIVER");

static void copy_mbr(u8* disk)
{
	memset(disk, 0x0, MBR_SIZE);
	*(unsigned long*)(disk + MBR_DISK_SIGNATURE_OFFSET) = 0x36E5756D;
	memcpy(disk + PARTITION_TABLE_OFFSET, &def_part_table, PARTITION_TABLE_SIZE);
	*(unsigned short*)(disk + MBR_SIGNATURE_OFFSET) = MBR_SIGNATURE;
}
static void copy_br(u8* disk, int abs_start_sector, const PartTable* part_table)
{
	disk += (abs_start_sector * SECTOR_SIZE);
	memset(disk, 0x0, BR_SIZE);
	memcpy(disk + PARTITION_TABLE_OFFSET, part_table,
		PARTITION_TABLE_SIZE);
	*(unsigned short *)(disk + BR_SIGNATURE_OFFSET) = BR_SIGNATURE;
}
void copy_mbr_n_br(u8* disk)
{
	int i = 0;
	copy_mbr(disk);
	for (; i < ARRAY_SIZE(def_log_part_table); ++i)
		copy_br(disk, def_log_part_br_abs_start_sector[i], &def_log_part_table[i]);
}
/* Structure associated with Block device*/
struct mydiskdrive_dev 
{
	int						size;
	u8*						data;
	spinlock_t 				lock;
	struct request_queue*	queue;
	struct gendisk*			gd;
 
}	device;
 
struct mydiskdrive_dev*	x;
 
static int my_open(struct block_device* x_, fmode_t mode_)	 
{
	int ret = 0;

	printk(KERN_INFO "mydiskdrive : open \n"); 
	return ret;
 
}
 
static void my_release(struct gendisk* disk_, fmode_t mode_)
{ printk(KERN_INFO "mydiskdrive : closed \n"); }
 
static struct block_device_operations fops =
{
	.owner = THIS_MODULE,
	.open = my_open,
	.release = my_release,
};
 
static int rb_transfer(struct request* req)
{
	int ret = 0;

	int dir = rq_data_dir(req);
	/*starting sector
	 *where to do operation*/
	sector_t start_sector = blk_rq_pos(req);
	unsigned int sector_cnt = blk_rq_sectors(req); /* no of sector on which opn to be done*/
	struct bio_vec bv;
	struct req_iterator iter;
	sector_t sector_offset;
	unsigned int sectors;
	u8* buffer;
	sector_offset = 0;
	rq_for_each_segment(bv, req, iter)
	{
		buffer = page_address(BV_PAGE(bv)) + BV_OFFSET(bv);
		if (BV_LEN(bv) % (SECTOR_SIZE) != 0)
		{
			printk(KERN_ERR"bio size is not a multiple ofsector size\n");
			ret = -EIO;
		}
		sectors = BV_LEN(bv) / SECTOR_SIZE;
		printk(KERN_DEBUG "my disk: Start Sector: %llu, Sector Offset: %llu;\
		Buffer: %p; Length: %u sectors\n",\
		(unsigned long long)(start_sector), (unsigned long long) \
		(sector_offset), buffer, sectors);
 
		if (dir == WRITE) /* Write to the device */
			memcpy((device.data)+((start_sector+sector_offset) * SECTOR_SIZE), buffer, sectors * SECTOR_SIZE);
		else /* Read from the device */
			memcpy(buffer,(device.data)+((start_sector+sector_offset) * SECTOR_SIZE), sectors * SECTOR_SIZE);	

		sector_offset += sectors;
	}
 
	if (sector_offset != sector_cnt)
	{
		printk(KERN_ERR "mydisk: bio info doesn't match with the request info");
		ret = -EIO;
	}
	return ret;
}
/** request handling function**/
static void dev_request(struct request_queue* q)
{
	struct request* req;
	int error;
	while ((req = blk_fetch_request(q)) != NULL) /*check active request for data transfer*/
	{
		error=rb_transfer(req);// transfer the request for operation
		__blk_end_request_all(req, error); // end the request
	}
}

int mydisk_init(void)
{
	device.data = vmalloc(MEMSIZE * SECTOR_SIZE);
	/* Setup its partition table */
	copy_mbr_n_br(device.data);
 
	return MEMSIZE;	
}
 
int device_setup(void)
{
	mydisk_init();
	if (device.data == NULL)
		return -ENOMEM;

	c = register_blkdev(c, "mydisk");// major no. allocation
	if (c <= 0)
	{
		printk(KERN_WARNING "unable to get major number\n");
		vfree(device.data);
		return -ENOMEM;
	}

	printk(KERN_ALERT "Major Number is : %d",c);

	spin_lock_init(&device.lock); // lock for queue
	device.queue = blk_init_queue(dev_request, &device.lock); //queue
	if (device.queue == NULL)
	{
		unregister_blkdev(c, "mydisk");
		vfree(device.data);
		return -ENOMEM;
	}
 
 	// gendisk init {
	device.gd = alloc_disk(8); 
	if (!device.gd)
	{
		unregister_blkdev(c, "mydisk");
		vfree(device.data);
		return -ENOMEM;
	}

 
	device.gd->major = c; // major no to gendisk
	device.gd->first_minor = 0; // first minor of gendisk
 
	device.gd->fops = &fops;
	device.gd->private_data = &device;
	device.gd->queue = device.queue;
	device.size= mydisk_init();	
	printk(KERN_INFO"THIS IS DEVICE SIZE %d",device.size);	
	sprintf(((device.gd)->disk_name), "mydisk");
	set_capacity(device.gd, device.size);  
	add_disk(device.gd);

	return 0;
}
 
static int __init mydiskdrive_init(void)
{ return device_setup(); }
 
 
void __exit mydiskdrive_exit(void)
{	
	del_gendisk(device.gd);
	put_disk(device.gd);
	blk_cleanup_queue(device.queue);
	unregister_blkdev(c, "mydisk");
	vfree(device.data);
}
 
module_init(mydiskdrive_init);
module_exit(mydiskdrive_exit);
