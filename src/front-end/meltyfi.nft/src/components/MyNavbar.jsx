import { Nav } from 'react-bootstrap';

function MyNavbar() {
    return (
        <div>
            <Nav className="justify-content-center" activeKey="/home" style={{ background: '#54251f' }}>
                <Nav.Item>
                    <Nav.Link href="/home" style={{ color: '#d9ad91' }}>Home</Nav.Link>
                </Nav.Item>
                <Nav.Item>
                    <Nav.Link href="/lotteries" style={{ color: '#d9ad91' }}>Lotteries</Nav.Link>
                </Nav.Item>
                <Nav.Item>
                    <Nav.Link href="/profile" style={{ color: '#d9ad91' }}>Profile</Nav.Link>
                </Nav.Item>
            </Nav>
        </div>
    );
}

export default MyNavbar;